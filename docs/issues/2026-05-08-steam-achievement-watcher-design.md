# Steam Achievement Watcher Design

## Goal

Extend the existing Steam watcher so Dian can notify groups when a bound player unlocks new Steam achievements in the game they are currently playing.

The new design should:

- preserve the existing status watcher behavior
- keep status and achievement concerns separate
- avoid duplicate notifications across restarts
- keep Steam API usage bounded
- include achievement display metadata, including icon URLs

## Scope

This design covers:

- polling and detecting newly unlocked achievements for the currently played game only
- grouped achievement notifications when multiple achievements unlock between polls
- caching Steam game achievement schema metadata
- persistence needed to avoid replaying old unlocks after restarts

This design does not cover:

- monitoring achievements for games the player is not currently playing
- historical achievement backfill
- frontend UI for achievement history or configuration

## Existing Context

The current watcher has a single poller and notifier pair:

- `Dian.SteamWatcher.Poller`
- `Dian.SteamWatcher.Notifier`

The poller batches `GetPlayerSummaries` requests for all bound Steam players, diffs in-memory snapshots, emits `StatusChanged` events via PubSub, and the notifier delivers group notifications.

That architecture is a good fit for achievements as long as achievement tracking is added as a parallel pipeline rather than folded into the status poller.

## Proposed Module Changes

Rename the current modules for clarity:

- `Dian.SteamWatcher.Poller` -> `Dian.SteamWatcher.StatusPoller`
- `Dian.SteamWatcher.Notifier` -> `Dian.SteamWatcher.StatusNotifier`

Add a parallel achievement pipeline:

- `Dian.SteamWatcher.AchievementPoller`
- `Dian.SteamWatcher.AchievementNotifier`
- `Dian.SteamWatcher.AchievementUnlocked`
- `Dian.Steam.GameSchema`

`Dian.SteamWatcher.Supervisor` should supervise both pipelines.

## Steam API Usage

### Status Detection

Use the existing `ISteamUser/GetPlayerSummaries/v0002` integration to determine:

- whether a player is currently in-game
- which `appid` they are currently playing
- the current game name

### Achievement State

Use `ISteamUserStats/GetPlayerAchievements/v0001` for one player and one app at a time.

This endpoint provides:

- achievement API name
- unlocked state
- unlock time
- localized name
- localized description

The response samples show a negative case with `success: false` and an error like `Requested app has no stats`. That should be treated as a cacheable session state.

### Achievement Schema

Use `ISteamUserStats/GetSchemaForGame/v0002` to fetch game-level achievement metadata keyed by `appid`.

This endpoint provides:

- schema achievement name
- display name
- description
- hidden flag
- unlocked icon URL
- locked icon URL

The design should use this schema primarily for icon URLs and fallback metadata enrichment.

## Polling Strategy

### Recommended Interval

Use a `5 minute` interval for the achievement poller.

Reasoning:

- achievement unlocks are infrequent enough that a short interval like `1-2 minutes` is not justified
- `10 minutes` is operationally cheap but makes notifications noticeably stale during long sessions
- `5 minutes` is conservative on API usage while still producing timely enough group notifications

### Final Exit Check

When a player is no longer playing a previously tracked game, the system must perform one final `GetPlayerAchievements` check for the prior `(steam_id, appid)` session before closing it.

This closes the correctness gap where a player unlocks achievements and exits the game before the next scheduled achievement poll.

## Session Model

Achievement tracking is session-oriented and keyed by `(steam_id, appid)`.

Each active session snapshot should store:

- `steam_id`
- `qq_id`
- `appid`
- `game_name`
- unlocked achievements keyed by `apiname`
- latest known `unlocktime` per unlocked achievement
- `last_checked_at`
- completion state

Completion state values:

- `:active`
- `:fully_unlocked`
- `:no_stats`
- `:private_or_unavailable`

## Persistence Model

To prevent duplicate notifications after restarts, snapshots must be persisted rather than stored only in GenServer state.

Add a table such as `steam_achievement_snapshots` with:

- `steam_id`
- `appid`
- `qq_id`
- `game_name`
- `unlocked_achievements`
- `completion_state`
- `last_checked_at`
- timestamps

Recommended uniqueness:

- unique index on `[:steam_id, :appid]`

`unlocked_achievements` can be stored as JSON containing the unlocked `apiname` set and unlock times.

An append-only event history table is optional. It is not required for first-version correctness if snapshot persistence is reliable.

## Detection Flow

### Session Start

When status polling shows that a player entered a game:

1. create or resume an achievement session for `(steam_id, appid)`
2. load any persisted snapshot for that same key
3. run an immediate baseline `GetPlayerAchievements` fetch
4. persist the resulting snapshot
5. emit no notification on first observation

The first observation is always a baseline, not a historical replay.

### In-Game Poll

On each achievement poll for an active session:

1. call `GetPlayerAchievements`
2. compare the unlocked set with the prior snapshot
3. collect all newly unlocked achievements in this window
4. if none are new, persist the latest check timestamp and continue
5. if one or more are new, emit a single grouped `AchievementUnlocked` event
6. persist the updated snapshot

### Session End

When status polling shows the player left the tracked game or switched apps:

1. perform one final achievement fetch for the old `(steam_id, appid)`
2. diff against the previous snapshot
3. emit one grouped event if new unlocks are found
4. persist the final snapshot state
5. mark the session inactive or remove it from in-memory scheduling

## Skip Rules

The poller should stop regular achievement checks for a session when:

- `GetPlayerAchievements` reports the app has no stats
- all achievements for the app are already unlocked

For these cases:

- mark the session state accordingly
- skip future periodic checks for that session
- still allow a new future session for the same `(steam_id, appid)` to reuse the persisted state

If the API is unavailable or the player profile does not expose the data, use `:private_or_unavailable` semantics and suppress notifications rather than failing the whole watcher.

## Event Shape

Emit one grouped event per player, game, and poll window.

`Dian.SteamWatcher.AchievementUnlocked` should contain:

- `steam_id`
- `qq_id`
- `appid`
- `game_name`
- `changed_at`
- `achievements`

Each item in `achievements` should contain:

- `api_name`
- `display_name`
- `description`
- `icon_url`
- `unlocktime`
- `hidden`

Grouping multiple unlocks into one event avoids notification spam when several achievements unlock between polls or during the exit check.

## Schema Cache Design

`Dian.Steam.GameSchema` should fetch and cache schema data keyed by:

- `appid`
- locale

Recommended behavior:

- fetch on cache miss
- cache successful schemas for a long TTL
- cache negative states such as missing schema or zero achievements
- expose a lookup by achievement API name so the poller can enrich events efficiently

The poller, not the notifier, should use schema cache lookups when building `AchievementUnlocked` events.

This keeps the notifier simple and ensures events are self-contained.

## Notification Design

`AchievementNotifier` should mirror the existing status notifier responsibilities:

- subscribe to achievement PubSub events
- resolve group targets
- resolve group member display name
- render and send a grouped achievement notification

The notifier should not own Steam schema fetching or achievement diff logic.

## Error Handling

### Achievement Fetch Failure

If a single achievement poll fails:

- log it with `steam_id` and `appid`
- keep the previous snapshot
- retry on the next interval

### Schema Fetch Failure

If schema enrichment fails:

- still emit the grouped event using data from `GetPlayerAchievements`
- leave `icon_url` and fallback metadata nil when unavailable
- avoid blocking unlock notifications on schema errors

### Status Poll Failure

A status polling failure should not mutate active achievement session state. The next successful status poll can resume normal lifecycle management.

## Testing Strategy

Add focused tests for:

- baseline creation does not emit events
- grouped unlock detection within one poll window
- final exit check emits missed unlocks before session close
- sessions marked `:no_stats` stop polling
- sessions marked `:fully_unlocked` stop polling
- schema cache enrichment adds icon URLs to event payloads
- schema fetch failure still allows grouped events with partial metadata
- persisted snapshots prevent duplicate replay after restart

Use explicit stubs per test case for Steam client responses. Avoid global mock behavior.

## Recommendation Summary

Recommended first implementation:

- rename the existing watcher modules to status-specific names
- add a parallel achievement poller and notifier
- poll active sessions every `5 minutes`
- always perform a final check on game exit
- persist per `(steam_id, appid)` snapshots
- emit grouped events with achievement metadata
- enrich icon URLs through a dedicated cached game schema module

This keeps the current watcher architecture intact while adding achievement monitoring with clear ownership boundaries and acceptable Steam API cost.
