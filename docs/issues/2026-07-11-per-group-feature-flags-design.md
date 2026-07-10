# Per-Group Feature Flags Design

## Goal

Add fine-grained per-group feature flags to `group_settings` so admins can independently opt each group into:

- Steam status-changed card delivery (from `SteamWatcher.StatusNotifier`)
- Steam achievement-unlocked card delivery (from `SteamWatcher.AchievementNotifier`)
- AI daily Steam summary delivery (from `AI.DailySteamSummary.Runner`)

These sit **below** the existing master `enabled` flag, which still gates everything.

## Scope

This design covers:

- migration adding three boolean columns to `group_settings`
- `GroupSetting` schema and changeset updates
- new `Dian.Settings` context query functions
- notifier and AI runner wiring swaps (delivery layer only)
- `Groups.update_group/3` write path
- OpenAPI schemas and controller response shape
- test fixtures and affected tests

This design does **not** cover:

- frontend UI (next phase — the backend schemas/controller here are the contract)
- poller gating (pollers stay global)
- exposing sub-flags in `GroupListResponse` / `GroupResponse`
- updates to the existing AI daily summary design doc (`2026-05-09-ai-daily-steam-summary-design.md`), which this plan supersedes on the "reuse enabled setting" point

## Existing Gating Flow

```
                           ┌─────────────────────────────┐
                           │  Dian.Settings.GroupSetting │
                           │   group_id  :string         │
                           │   enabled   :boolean       │
                           └─────────────┬───────────────┘
                                         │
        ┌────────────────────────────────┼───────────────────────────────┐
        ▼                                ▼                                 ▼
  group_enabled?/1            list_enabled_group_ids/0              update_group_setting/2
  (per-group gate)            (returns all enabled)                  (write back)
        │                                │
        │                                ├─▶ SteamWatcher.StatusNotifier.notification_targets/1
        │                                ├─▶ SteamWatcher.AchievementNotifier.notify/1
        │                                └─▶ AI.DailySteamSummary.Runner.run/1
        │
        ├─▶ Groups.enrich_group/1  (UI shows enabled state)
        ├─▶ Settings.user_in_enabled_groups?/1  (registration gating)
        └─▶ Groups.update_group/3  (only allows Map.take(attrs, ["enabled"]))
```

Key observation: the two Steam pollers do **not** consult `enabled`. They poll every
bound Steam player unconditionally and persist play sessions / achievement snapshots.
The **notifiers** call `Settings.list_enabled_group_ids/0` to decide which groups to
deliver cards to. So `enabled` today is a **delivery gate**, not a polling gate.

The AI daily summary runner injects `list_enabled_group_ids` as an option and iterates
over the returned group IDs.

## Semantics

``                                            ┌──────── master gate ────────┐
                                            │  enabled == true (required) │
                                            └──────────────┬───────────────┘
                                                           │
            ┌──────────────────┬───────────────────────────┼─────────────────────┐
            ▼                  ▼                           ▼                     ▼
  steam_status_enabled  steam_achievements_enabled  daily_steam_summary_enabled
  (StatusNotifier)      (AchievementNotifier)        (AI.DailySteamSummary.Runner)
```

- `enabled == false` → nothing delivered at all (master gate wins; sub-flags irrelevant)
- `enabled == true` → each sub-flag independently gates its own delivery channel
- Global AI feature flag (`AI.enabled?/0` env gate) stays — it's a separate, additional
  gate for the AI summary only
- `list_enabled_group_ids/0` is still used by `Settings.user_in_enabled_groups?/1`
  (registration gating uses master `enabled` only, unchanged)

## Decision: Delivery-Only Gating

Pollers keep polling everyone unconditionally; only the notifiers skip groups with the
sub-flag off. This keeps AI daily summary's play-session input intact when status cards
are disabled. Gating polling would save Steam API calls but break the AI summary's
play-session data for groups that turned off status cards.

## Defaults

All three new columns `default: false`, `null: false`. No backfill — clean break. All
existing and new rows start with every sub-flag off; admins opt in per group.

## Implementation

### 1. Migration

```
# priv/repo/migrations/<timestamp>_add_per_group_feature_flags_to_group_settings.exs

def change do
  alter table(:group_settings) do
    add :steam_status_enabled,         :boolean, default: false, null: false
    add :steam_achievements_enabled,   :boolean, default: false, null: false
    add :daily_steam_summary_enabled,  :boolean, default: false, null: false
  end
end
```

### 2. Schema — `lib/dian/settings/group_setting.ex`

```
field :enabled,                     :boolean, default: false   # existing
field :steam_status_enabled,        :boolean, default: false   # new
field :steam_achievements_enabled,  :boolean, default: false    # new
field :daily_steam_summary_enabled, :boolean, default: false   # new
```

`changeset/2` casts all three new fields alongside `:group_id, :enabled`.
`validate_required` stays as-is on `[:group_id, :enabled]` so partial patches
(flip just one sub-flag) keep working with `insert_or_update`.

### 3. Settings Context — `lib/dian/settings.ex`

```
keep:
  group_enabled?/1                       # master gate (registration, UI)
  list_enabled_group_ids/0              # still used for user_in_enabled_groups?/1
  get_group_setting/1
  update_group_setting/2

add:
  list_steam_status_target_ids/0
    from g in GroupSetting,
      where: g.enabled == true and g.steam_status_enabled == true,
      select: g.group_id

  list_steam_achievements_target_ids/0
    from g in GroupSetting,
      where: g.enabled == true and g.steam_achievements_enabled == true,
      select: g.group_id

  list_daily_steam_summary_target_ids/0
    from g in GroupSetting,
      where: g.enabled == true and g.daily_steam_summary_enabled == true,
      select: g.group_id
```

### 4. Notifier and AI Runner Wiring Swaps

```
StatusNotifier.notification_targets/1   (lib/dian/steam_watcher/status_notifier.ex:100-102)
  before:  Settings.list_enabled_group_ids()
  after:   Settings.list_steam_status_target_ids()

AchievementNotifier.notify/1            (lib/dian/steam_watcher/achievement_notifier.ex:49)
  before:  Settings.list_enabled_group_ids()
  after:   Settings.list_steam_achievements_target_ids()

AI.DailySteamSummary.Runner.run/1       (lib/dian/ai/daily_steam_summary/runner.ex:20-21)
  before:  Keyword.get(opts, :list_enabled_group_ids, &Settings.list_enabled_group_ids/0)
  after:   Keyword.get(opts, :list_target_group_ids,
                      &Settings.list_daily_steam_summary_target_ids/0)

unchanged:
  StatusPoller, AchievementPoller        # poll all bindings, persist sessions/snapshots
  AI.enabled?/0                          # global env gate unchanged
  Settings.user_in_enabled_groups?/1     # registration keeps using master enabled
```

### 5. Write Path — `lib/dian/groups.ex`

```
Groups.update_group/3   (lib/dian/groups.ex:41-45)
  before:  Map.take(attrs, ["enabled"])
  after:   Map.take(attrs, ["enabled",
                            "steam_status_enabled",
                            "steam_achievements_enabled",
                            "daily_steam_summary_enabled"])
```

### 6. API Schemas

```
GroupUpdateRequest   (lib/dian_web/schemas/group_update_request.ex)
  properties add:
    steam_status_enabled:         boolean
    steam_achievements_enabled:   boolean
    daily_steam_summary_enabled:  boolean
  ⚠️ Currently required: [:enabled]. Relax to [] (or remove the required
    list) so admins can patch a single sub-flag without resending enabled.
    The changeset + insert_or_update already handle partial updates.

GroupSettingsResponse  (lib/dian_web/schemas/group_settings_response.ex)
  group.properties add:
    steam_status_enabled:         boolean
    steam_achievements_enabled:   boolean
    daily_steam_summary_enabled:  boolean
  required: [:id, :enabled, :steam_status_enabled,
             :steam_achievements_enabled, :daily_steam_summary_enabled]

GroupListResponse / GroupResponse   ← unchanged
```

### 7. Controller — `lib/dian_web/controllers/group_controller.ex`

```
GroupController.update/2   (line 64-69)
  success body  before:  %{id: group_id, enabled: group_setting.enabled}
  success body  after:   %{id: group_id,
                            enabled: group_setting.enabled,
                            steam_status_enabled: group_setting.steam_status_enabled,
                            steam_achievements_enabled: group_setting.steam_achievements_enabled,
                            daily_steam_summary_enabled: group_setting.daily_steam_summary_enabled}
```

### 8. Fixtures — `test/support/fixtures/settings_fixtures.ex`

```
enabled_group_setting_fixture/1
  defaults:  enabled: true  (unchanged)
             steam_status_enabled: false
             steam_achievements_enabled: false
             daily_steam_summary_enabled: false
  explicit per-test opt-in:
    enabled_group_setting_fixture(group_id: "100",
      steam_status_enabled: true)
```

### 9. Test Updates

```
test/dian/steam_watcher/notifier_test.exs
  → add steam_status_enabled: true to fixtures for status delivery tests
  → lines 194, 253-254

test/dian/steam_watcher/achievement_notifier_test.exs
  → add steam_achievements_enabled: true to fixtures for achievement delivery tests
  → lines 64, 158-159, 263, 356

test/dian/ai_test.exs
  → add daily_steam_summary_enabled: true to enabled_group_setting_fixture calls
    in run_daily_group_summaries describe block
    (lines 48, 100-101, 143, 166, 190)
  → the "skips the whole run when AI is disabled" test (line 91) needs no change
    (AI.enabled?() short-circuits before any group lookup)
  → any test injecting :list_enabled_group_ids opts key needs to switch to
    :list_target_group_ids (currently none do — they rely on the default)

test/dian/groups_test.exs
  → extend update_group test to assert new fields round-trip
    (e.g. update with one sub-flag and assert returned GroupSetting)
```

### 10. Verification

```
mix precommit
```

## Implementation Order

```
 1. Migration          mix ecto.gen.migration add_per_group_feature_flags_to_group_settings
 2. Schema             GroupSetting: add 3 fields + cast in changeset
 3. Settings context   add list_steam_status_target_ids/0
                       add list_steam_achievements_target_ids/0
                       add list_daily_steam_summary_target_ids/0
 4. Notifier wiring    StatusNotifier.notification_targets/1
                       AchievementNotifier.notify/1
                       Runner.run/1 (opt key rename + default swap)
 5. Groups context     update_group/3 Map.take to include 3 new keys
 6. API schemas        GroupUpdateRequest (add props, relax required)
                       GroupSettingsResponse (add props, required)
 7. Controller         GroupController.update/2 success body
 8. Fixtures           enabled_group_setting_fixture add 3 sub-flag defaults
 9. Tests              notifier_test, achievement_notifier_test,
                       ai_test, groups_test
10. Verify             mix precommit
```

## Out of Scope

- Frontend UI (next phase — the schemas/controller here are the contract)
- Poller gating (pollers stay global)
- Exposing sub-flags in `GroupListResponse` / `GroupResponse`
- Updates to the existing AI daily summary design doc
  (`docs/issues/2026-05-09-ai-daily-steam-summary-design.md`), which this plan
  supersedes on the "reuse enabled setting" point