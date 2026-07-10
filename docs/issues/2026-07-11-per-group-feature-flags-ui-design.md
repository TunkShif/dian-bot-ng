# Per-Group Feature Flags UI Design

## Goal

Evolve the group details settings panel from a single master switch into a
two-step interaction: enable the bot first, then opt into individual delivery
features (Steam status, achievements, daily AI summary).

## Scope

This design covers:

- progressive disclosure of per-feature toggles beneath the master switch
- visual layout, animation, and interaction model for the settings panel
- copy and i18n updates for the master description and feature rows
- transient post-enable hint behavior

This design does **not** cover:

- changes to the group list table or `GroupStatusBadge` (stays master-only)
- backend changes to `GroupListResponse` / `GroupResponse` (sub-flags stay
  update-only, exposed via `GroupSettingsResponse` and `GroupUpdateRequest`)
- batch-save buttons (per-toggle PATCH, existing pattern)

## Interaction Model

```
  Master off                          Master on
  ┌─────────────────────┐              ┌─────────────────────────────┐
  │ Bot availability    │              │ Bot availability             │
  │ [switch OFF]        │              │ [switch ON]                  │
  │                     │              │                              │
  │ (nothing else here) │              │ ✓ Bot enabled — turn on the │
  │                     │              │   features below.            │
  │                     │              │                              │
  │                     │              │ 🎮 Steam status      [○ ⊚]  │
  │                     │              │ ⚫ Achievements      [○ ⊚]  │
  │                     │              │ ✨ Daily AI summary  [○ ⊚]  │
  └─────────────────────┘              └─────────────────────────────┘
```

### Semantics

- master OFF → sub-toggles hidden entirely; OFF state stays visually identical
  to today's single-switch panel
- master ON → sub-toggles render via CSS reveal animation, independently mutable
- master ON then OFF → sub-toggles hide again; backend preserves sub-flag values
  in DB; re-enabling restores them as-is
- admin OFF → everything disabled as today
- each sub-toggle sends its own PATCH with `{ <flag>: true|false }` on flip

## Decisions

| Decision | Choice |
|---|---|
| Master OFF state | Sub-toggles hidden entirely |
| Master copy | Updated to telegraph two-step model |
| Post-enable nudge | Transient hint until any sub-flag goes ON |
| List table badge | Stays master-only (no backend list/show changes) |
| Per-toggle mutation | Individual PATCH per flag (existing pattern) |
| Animation | CSS via `data-state` mechanism (matches accordion pattern) |
| Layout | Flat rows in inner bordered container with thin dividers |
| Feature icons | Phosphor: `GameControllerIcon` / `TrophyIcon` / `SparklesIcon` |

## Layout

```
┌─ Settings panel (rounded, bordered, bg-muted/30) ───────────────┐
│  ⚙ Bot availability                                [switch]    │
│  Enable this group to allow bot commands. Then opt into                    │
│  individual features below.                                                │
│                                                                  │
│  [revealed block, only when enabled, animated]                  │
│  ╭──────────────────────────────────────────────────╮           │
│  │ ✓ Bot enabled — turn on the features below.    │           │ ← transient
│  │                                                   │           │   hint,
│  │ 🎮 Steam status                          [○ ⊚]  │           │   fades
│  │   Post a card when a member starts playing.      │           │   when any
│  │ ────────────────────────────────────────────── │           │   sub-flag
│  │ 🏆 Achievements                          [○ ⊚]  │           │   → ON
│  │   Post a card when a member unlocks an item.     │           │
│  │ ────────────────────────────────────────────── │           │
│  │ ✨ Daily AI summary                      [○ ⊚]  │           │
│  │   Generate a daily play-activity summary.       │           │
│  ╰──────────────────────────────────────────────────╯           │
└──────────────────────────────────────────────────────────────────┘
```

## Feature Metadata

| flag | Phosphor icon | label (en / zh) | description (en / zh) |
|---|---|---|---|
| `steam_status_enabled` | `GameControllerIcon` | "Steam status" / "Steam 动态" | "Post a card when a member starts playing a game." / "成员开始游戏时发送一张动态卡。" |
| `steam_achievements_enabled` | `TrophyIcon` | "Achievements" / "成就解锁" | "Post a card when a member unlocks an achievement." / "成员解锁成就时发送一张成就卡。" |
| `daily_steam_summary_enabled` | `SparklesIcon` | "Daily AI summary" / "每日 AI 总结" | "Generate a daily play-activity summary with AI." / "用 AI 生成每日游戏活动总结。" |

Icon rationale: `SparklesIcon` over `RobotIcon` for AI — sparkles maps to the
"lighthearted summary" tonality of the daily summary feature.

## Transient Hint Logic

```
showHint =
    group.enabled
    && !group.steam_status_enabled
    && !group.steam_achievements_enabled
    && !group.daily_steam_summary_enabled
```

Behavior:

- shows when the user has just enabled the bot but no feature is on yet
- persists across renders while all sub-flags remain off
- disappears the moment any sub-flag goes ON
- does **not** return if the user toggles everything back off (the "nudge"
  moment has passed) — implementation: track `hasEverEnabledFeature` local
  state, initialized from the current sub-flag state on mount

## Component Structure

```
group-details.tsx
└─ GroupSettingsSection
   ├─ master switch row (existing)
   ├─ FeatureTogglesBlock (revealed when enabled)
   │  ├─ transient hint (conditional)
   │  └─ GroupFeatureToggle × 3
   │     ├─ icon + label
   │     ├─ description
   │     └─ Switch
```

`GroupSettingsSection` is extracted from `group-details.tsx` to keep the main
component focused on layout and member display. `GroupFeatureToggle` is a
reusable row component for each flag.

## Mutation Strategy

Per-toggle PATCH (existing `updateGroupMutation`):

```
master switch  → PATCH { enabled: true|false }
sub-toggle     → PATCH { steam_status_enabled: true|false }
                or { steam_achievements_enabled: true|false }
                or { daily_steam_summary_enabled: true|false }
```

Both followed by invalidating `listGroups` and `showGroup` query keys on
success (existing pattern). The backend supports partial updates on
`GroupUpdateRequest` (no fields required).

## i18n Keys

Add under `app.groups.settings.features.*` namespace:

```
features.label                              "Features"                    / "功能"
features.steamStatus.label                  "Steam status"                / "Steam 动态"
features.steamStatus.description            "Post a card when a member starts playing a game."
                                            / "成员开始游戏时发送一张动态卡。"
features.achievements.label                 "Achievements"                / "成就解锁"
features.achievements.description           "Post a card when a member unlocks an achievement."
                                            / "成员解锁成就时发送一张成就卡。"
features.dailySummary.label                 "Daily AI summary"            / "每日 AI 总结"
features.dailySummary.description            "Generate a daily play-activity summary with AI."
                                            / "用 AI 生成每日游戏活动总结。"
features.disabledHint                       "Enable the bot to configure features."
                                            / "先启用机器人才能配置这些功能。"
features.enabledHint                        "Bot enabled — turn on the features below."
                                            / "机器人已启用，在下方打开你想要的功能。"
```

Update existing key:

```
settings.description                        "Enable this group to allow bot commands. Then opt into individual features below."
                                            / "启用该群组以使用机器人命令，然后在下方开启你想要的功能。"
```

All keys must be added to all 11 locales: `en, zh, yue, lzh, ja, tr, ru, fr,
es, el, de`. Use `en` content as placeholder for untranslated locales if no
ready translations exist.

## Animation Mechanic

Use CSS `data-state` mechanism matching the existing accordion component:

- wrap the sub-toggle block in a container with `data-state={enabled ? "open" : "closed"}`
- height + opacity transition via `data-open:animate-*` / `data-closed:animate-*` Tailwind utilities
- keep the transition small (~150ms total)
- no new animation library (framer-motion is not a project dependency)

## Implementation Order

```
1. Document           (this file, complete)
2. Regenerate API client if needed (check GroupUpdateRequest/GroupSettingsResponse in types.gen.ts)
3. Extract GroupSettingsSection from group-details.tsx
4. Add GroupFeatureToggle row component
5. Add FeatureTogglesBlock with reveal animation + transient hint
6. Wire up mutations for each sub-flag
7. i18n: add new keys to all 11 locale files
8. Update master description copy
9. Build + typecheck
```

## Out of Scope

- Group list badge evolution (requires backend `GroupListResponse` changes)
- Batch save button
- Per-feature scheduling / configuration (e.g. what time the daily summary runs)
- Separate "Feature summary" view showing historical delivery state per feature