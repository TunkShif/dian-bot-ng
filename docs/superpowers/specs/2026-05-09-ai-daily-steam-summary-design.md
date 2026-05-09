# AI Daily Steam Summary Design

## Goal

Generate one daily Steam play summary, roast, or joke message for each enabled group using the previous day's persisted play sessions.

The design should:

- use `ReqLLM` with the DeepSeek provider
- remain globally opt-in so deployments without AI credentials or budget can ignore the feature entirely
- reuse the existing group enabled setting instead of adding new per-group AI settings
- keep group delivery independent from Steam session capture

## Scope

This design covers:

- context boundaries for AI generation
- runtime configuration and opt-in gating
- daily scheduling at `10:00 UTC+8`
- building prompt input from persisted Steam play sessions
- generating and sending one message per enabled group

This design does not cover:

- frontend UI for AI settings
- persisted AI history or prompt audit tables
- per-group AI customization
- moderation beyond simple prompt constraints and failure handling

## Existing Context

The app already has the core ingredients needed for this feature:

- `Dian.Settings.list_enabled_group_ids/0` returns groups where the bot is enabled
- `DianBot.get_group_member_list/1` returns current group membership
- `Dian.Steam.get_steam_players_by_qq_ids/1` maps group members to bound Steam players
- `Dian.Steam.list_play_sessions_for_players/2` returns persisted play sessions for later reporting
- existing watcher notifiers already follow the pattern of resolving groups and sending one message per group

The codebase does not currently use a dedicated job framework such as Oban or Quantum. Existing runtime scheduling is implemented with GenServer timers.

## Context Design

### Actors

- scheduler actor: wakes daily and coordinates one run across enabled groups
- external system actor: DeepSeek LLM API accessed through `ReqLLM`
- read-side consumer actor: enabled groups receiving generated summaries

### Context Owners

- `Dian.AI` owns AI feature gating, prompt generation, and LLM client integration
- `Dian.Steam` remains the owner of persisted play-session data
- `Dian.Settings` remains the owner of enabled-group settings
- `DianBot` remains the message delivery boundary

### Table Ownership

No new database table is required for v1.

The feature should read from `steam_play_sessions` but should not write new AI-specific records in the first version.

## Feature Gating

The AI feature should be globally opt-in.

Recommended gate:

- `ENABLE_AI_DAILY_SUMMARY=true`
- `DEEPSEEK_API_KEY` present

If either condition is missing:

- the AI scheduler should no-op cleanly or not start its delivery cycle
- the application should continue operating normally
- no user-facing errors should be produced

This keeps the feature safe for deployers who do not want AI behavior or cannot justify LLM costs.

## Provider Integration

Use `ReqLLM` with the DeepSeek provider.

Recommended defaults:

- provider/model: `deepseek:deepseek-chat`
- API key: `DEEPSEEK_API_KEY`
- model name overridable through runtime config for future tuning

The `Dian.AI` context should hide `ReqLLM` details behind a small public API so the rest of the app does not couple directly to provider-specific request shape.

## Scheduling Approach

Use a GenServer-based daily scheduler, following the existing app pattern rather than introducing a cron dependency.

Recommended module:

- `Dian.AI.DailySteamSummaryScheduler`

Behavior:

1. compute the next `10:00 UTC+8` run time
2. schedule a timer for that wall-clock instant
3. when the timer fires, execute the daily generation flow
4. after completion, schedule the next day's run

The scheduler should operate in Asia/Shanghai local business time for the target behavior, while stored timestamps remain UTC.

## Recommended Module Split

- `Dian.AI`
  Public entry points and feature enablement checks.
- `Dian.AI.Client`
  Wraps `ReqLLM` and DeepSeek request/response handling.
- `Dian.AI.DailySteamSummary`
  Builds structured prompt input from Steam sessions and turns the LLM result into a final group message.
- `Dian.AI.DailySteamSummaryScheduler`
  Schedules and coordinates the once-daily run.

This keeps the scheduler, prompt builder, and provider integration separate so model/provider changes do not affect scheduling logic.

## Daily Generation Flow

For each scheduled run:

1. confirm the AI feature is enabled
2. fetch enabled group ids using existing settings
3. for each group, fetch the current member list
4. map members to bound Steam players
5. fetch yesterday's play sessions for those player QQ IDs
6. skip groups with no bound Steam players or no sessions
7. build a compact structured prompt input
8. call DeepSeek via `ReqLLM`
9. send the resulting message to the group
10. continue even if one group fails

The run should be best-effort. One group failure must not block the others.

## Date Window

At `10:00 UTC+8`, the scheduler should summarize the previous local calendar day in `UTC+8`.

Example:

- run time: `2026-05-10 10:00 UTC+8`
- summarized window: `2026-05-09 00:00:00` through `2026-05-09 23:59:59` in `UTC+8`

The implementation should convert that local window to the query shape expected by `Dian.Steam.list_play_sessions_for_players/2`.

## Prompt Input Design

The LLM input should be structured and fact-based.

Recommended payload:

- target date
- group id and optionally group name
- list of players included in the summary
- per-player sessions:
  - game name
  - started_at
  - ended_at
  - duration_seconds
- derived per-player stats:
  - total playtime
  - games played
  - top game
  - session count
  - longest session
  - first game
  - last game
- derived group-level stats:
  - total group playtime
  - most played game
  - player with longest playtime
  - player with most switches

The prompt should make it easy for the model to summarize or joke from facts instead of reconstructing analytics itself.

## Prompt Contract

Recommended system guidance:

- write a concise daily summary for a chat group
- be playful and lightly teasing, never cruel
- stay grounded in the provided facts
- do not invent players, games, or durations
- if the data is sparse, prefer a mild summary over forced jokes

Recommended output constraints:

- one final message
- around `3-6` short lines or compact paragraphs
- mention only players with actual sessions
- keep tone friendly and lightweight

## Sparse Data Behavior

If the group's data is too thin for roasting:

- fall back to a gentle summary
- avoid trying to force punchlines from one short session or minimal activity

If there are no sessions at all:

- skip the group entirely
- send nothing

This keeps the feature from feeling noisy or low-quality on quiet days.

## Error Handling

Failure handling should be intentionally forgiving:

- AI disabled: skip the whole run
- no enabled groups: skip the run
- group member fetch fails: log and continue
- no bound Steam players: skip that group
- no sessions in the target window: skip that group
- LLM request fails: log and continue
- group message send fails: log and continue

No failure in one group should stop the rest of the scheduled run.

## Logging

Log enough to understand scheduler behavior and provider health:

- scheduler started
- next scheduled run time
- run started and finished
- group count processed
- groups skipped due to no data
- LLM request failures
- message delivery failures

Avoid logging raw prompts or full generated content in v1 unless there is a clear debugging need, because that can create cost, privacy, and noise issues.

## Public APIs

Recommended public API on `Dian.AI`:

- `enabled?/0`
- `generate_daily_group_summary(group_context)`
- `run_daily_group_summaries/0`

Where `group_context` is a plain map or struct containing:

- `group_id`
- `group_name`
- `date`
- `members`
- `sessions`
- derived stats

The rest of the app should call these public APIs rather than using `ReqLLM` directly.

## Future Extension Points

The first version should remain intentionally lean, but this design leaves room for:

- alternate LLM providers
- configurable model selection
- per-group prompt styles
- storing generated summary history
- manual “generate today’s summary now” triggers

Those should be future work, not part of v1.

## Testing

Focus tests on feature gating, scheduler behavior, and prompt generation boundaries.

Suggested tests:

- AI disabled when env flag is false
- AI disabled when API key is missing
- scheduler computes the next `10:00 UTC+8` run correctly
- groups with no bound Steam players are skipped
- groups with no sessions are skipped
- prompt builder includes expected derived stats and session facts
- LLM failure for one group does not stop the rest
- delivery failure for one group does not stop the rest

Mock the LLM client at the `Dian.AI.Client` boundary rather than mocking `ReqLLM` deep inside the feature.

## Risks And Non-Goals

Known trade-offs:

- generated tone quality depends on model behavior
- one daily summary may still occasionally be bland for sparse data
- no persisted AI history means generated output is ephemeral

These are acceptable for the first version because the immediate goal is lightweight daily group commentary, not a full AI analytics product.
