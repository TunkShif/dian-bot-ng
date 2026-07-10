# Steam Play Session History Design

## Goal

Persist rough Steam play history for bound players so Dian can later generate group-specific summaries, jokes, and AI-driven commentary about what members played yesterday.

The design should:

- reuse the existing Steam watcher pipeline
- keep capture independent from group-specific reporting
- accept rough timing based on polling rather than exact launch/exit timestamps
- keep the first version small and cheap to operate

## Scope

This design covers:

- inferring player-scoped Steam play sessions from the existing status poller
- persisting only finalized sessions
- storing enough metadata to support later AI summarization and roasting
- context boundaries between `SteamWatcher` runtime logic and `Steam` persistence

This design does not cover:

- exact session timing or raw poll history
- group message generation or scheduling
- frontend UI for browsing play history
- historical backfill from Steam APIs

## Existing Context

The current watcher already polls Steam player summaries for all bound Steam players:

- `Dian.SteamWatcher.StatusPoller`
- `Dian.SteamWatcher.StatusChanged`

`StatusPoller` keeps in-memory summary snapshots keyed by `steam_id` and emits a `StatusChanged` event when the currently played game changes.

This makes play history a natural downstream feature of the watcher rather than a new polling subsystem. The existing `Steam` context already owns Steam bindings and persisted Steam-related tables, so it should also own the session table and public persistence APIs.

## Context Design

### Actors

- `SteamWatcher` is a scheduler-driven machine actor that observes Steam state and infers transitions.
- `Steam` is the domain/storage owner for Steam-related persisted records.
- future AI summarization is a read-side consumer that will query sessions later using group member lists.

### Table Ownership

- `steam_play_sessions` table owner: `Dian.Steam`
- table writer: `Dian.Steam` only

### Boundary Split

`Dian.SteamWatcher` should own runtime inference:

- detecting when a session starts
- keeping in-memory open-session candidates
- deciding when a session ends
- classifying end reason

`Dian.Steam` should own persistence:

- `PlaySession` schema
- session insert APIs
- query APIs for later reporting

Cross-context interaction should use public APIs and raw IDs only. `SteamWatcher` should call `Steam.create_play_session/1` with plain attributes rather than importing repo logic directly.

## Recommended Approach

Use player-scoped sessions and persist only closed sessions.

Reasoning:

- the current poller is global and has no group awareness
- one player may belong to multiple groups, so group-scoped persistence would duplicate the same session multiple times
- later group-specific summaries can be built by taking a group's member list and filtering global sessions by those players

Rejected alternatives:

- group-scoped sessions: duplicates storage and couples watcher capture to group membership
- raw poll log storage: increases write volume and complexity without helping the immediate summarization goal
- persisting open sessions: adds extra writes and recovery complexity that are not needed for rough daily summaries

## Data Model

Add a `steam_play_sessions` table with one row per finalized inferred session.

Recommended fields:

- `qq_id`
- `steam_id`
- `app_id`
- `game_name`
- `player_display_name`
- `started_at`
- `ended_at`
- `duration_seconds`
- `session_end_reason`
- timestamps

Recommended `session_end_reason` values:

- `:stopped`
- `:switched`
- `:poll_gap`

Recommended indexes:

- index on `[:qq_id, :started_at]`
- index on `[:steam_id, :started_at]`
- index on `[:app_id, :started_at]`

No uniqueness constraint is required beyond the primary key. Multiple sessions for the same player and app on the same day are valid.

## Runtime Model

The tracker should keep only in-memory open-session candidates keyed by `steam_id`.

Each open candidate should contain:

- `qq_id`
- `steam_id`
- `app_id`
- `game_name`
- `player_display_name`
- `started_at`
- `last_seen_at`

The persisted table contains only finalized sessions. If the watcher process restarts, any open in-memory sessions are lost. That is acceptable for this feature because the product goal explicitly tolerates rough accuracy.

## Detection Flow

### Session Start

When polling observes a player in a game and there is no open candidate:

1. open an in-memory candidate for that `steam_id`
2. set `started_at` and `last_seen_at` to the current observed timestamp
3. write nothing yet

This means the recorded start time is the first observation of the session, not the true launch time.

### Session Continuation

When polling observes the same player still in the same game:

1. update `last_seen_at`
2. keep the candidate open
3. write nothing

### Game Switch

When polling observes a player move from `game A` to `game B`:

1. finalize the open candidate for `game A`
2. set `ended_at` to the current observed timestamp
3. compute `duration_seconds` from `started_at` to `ended_at`
4. persist the finalized row with `session_end_reason = :switched`
5. open a new candidate for `game B`

### Session Stop

When polling observes a player move from `game A` to not playing:

1. finalize the open candidate for `game A`
2. set `ended_at` to the current observed timestamp
3. compute `duration_seconds`
4. persist the row with `session_end_reason = :stopped`

### Poll Gap

If the tracker needs to close a session because the player's current playing state can no longer be reliably observed, finalize the row with `session_end_reason = :poll_gap`.

First version recommendation:

- keep `poll_gap` support in the design and API
- only use it when the implementation can detect a real observation gap cleanly
- do not add extra complexity just to force this path immediately

## Accuracy Model

The system should be explicit about its roughness:

- `started_at` is the first poll where the game was observed
- `ended_at` is the poll where stop or switch was observed
- duration is approximate to the watcher interval

This is acceptable because the feature is for narrative summaries and roasts, not billing, competitive analytics, or exact playtime accounting.

## Module Responsibilities

Recommended module split:

- `Dian.SteamWatcher.StatusPoller`
  Polls Steam summaries and passes transition facts into the tracker.
- `Dian.SteamWatcher.PlaySessionTracker`
  Owns in-memory candidates and finalizes sessions on stop, switch, or gap.
- `Dian.Steam.PlaySession`
  Ecto schema for persisted finalized sessions.
- `Dian.Steam`
  Public API for creating and querying play sessions.

The tracker should live under `SteamWatcher`, not `Steam`, because session inference changes for watcher-specific reasons such as polling behavior, gap handling, and transition rules. The table and insert/query APIs should live under `Steam` because `Steam` is the source-of-truth owner of persisted Steam data.

## Public APIs

Recommended additions to `Dian.Steam`:

- `create_play_session(attrs)`
- `list_play_sessions_for_player(qq_id, date_range)`
- `list_play_sessions_for_players(qq_ids, date_range)`

The first API is required for the watcher integration. The query APIs are aimed at later AI/reporting use and can be implemented in the same context because they read the table owned by `Steam`.

## Future Reporting Flow

This feature intentionally keeps group logic out of capture.

Later group-oriented summarization should work like this:

1. list group members for a target group
2. map members to bound Steam players
3. fetch yesterday's `steam_play_sessions` for those `qq_id`s
4. build per-group prompts and summaries from the filtered session set
5. send the resulting message to that group

This avoids duplicating sessions for players who belong to multiple groups while still allowing tailored group-specific output.

## Testing

Focus tests on transition semantics and persistence correctness.

Tracker tests:

- first observed in-game session opens a candidate and does not write
- same game across multiple polls updates the candidate and does not write
- switching games writes the previous session and opens the next one
- stopping play writes the session
- gap closure writes `:poll_gap` when exercised

Persistence tests:

- inserted row stores the expected player and game fields
- `duration_seconds` is computed from observed timestamps
- multiple sessions for the same player and app are allowed

No tests should assume exact real-world launch or exit timestamps beyond the observed poll times.

## Risks And Non-Goals

Known trade-offs:

- a watcher restart can lose currently open sessions
- very short sessions between polls may never be observed
- session start and end times can drift by up to roughly one polling interval

These are acceptable non-goals for the first version because the product need is rough daily storytelling, not precise telemetry.
