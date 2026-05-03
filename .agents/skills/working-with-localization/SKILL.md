---
name: working-with-localization
description: Use when changing frontend user-facing text, adding React Router UI copy, editing i18next locale files, fixing missing translation keys, or reviewing hardcoded strings in this Phoenix React SPA
---

# Working With Localization

## Overview

Localization lives only in the frontend `assets` app. Treat every user-facing frontend string as locale data unless it is a code-only identifier, test fixture, or intentionally ignored third-party UI primitive copy.

## Required Scope

- Only localize frontend code under `assets`.
- Supported locales are defined in `assets/i18next.config.ts` and `assets/js/lib/locales.ts`; keep both lists aligned.
- Locale strings live in `assets/public/locales/{locale}/{namespace}.json`; currently this app uses `translation.json`.

## Key Structure Convention

Use dot paths that describe product area, screen or feature, component group, and UI role:

```text
{area}.{screenOrFeature}.{group}.{role}
```

Current roots:

| Root | Use For |
| --- | --- |
| `auth.*` | Authentication route copy and login/register flow text |
| `app.*` | Shared app shell, navigation, reusable actions, auth guards, and dashboard shell text |

- Put route-specific copy under the owning route or feature root, such as `auth.login.emailStep.title`.
- Put reused shell and cross-feature labels under `app.nav`, `app.actions`, `app.userMenu`, `app.auth`, or a similarly specific shared group.
- Name leaf keys by UI role, not by English text: `title`, `description`, `label`, `placeholder`, `errorMessage`, `successTitle`, `successMessage`, `imageAlt`.
- Group repeated component variants by stable domain names: `app.dashboard.cards.revenue.label`, not `card1Title`.
- Keep keys stable when English copy changes; rename keys only when the meaning or ownership changes.
- Use semantic camelCase to match the existing JSON and generated TypeScript types.
- Avoid vague buckets like `common.misc` or `messages`; choose the smallest clear owner.
- Do not duplicate reusable labels in feature trees. Move genuinely shared labels to `app.actions` or another shared group.

## Implementation

Inside React components, use `useTranslation`:

```tsx
const { t } = useTranslation();

return <Button>{t("auth.login.emailStep.continue")}</Button>;
```

Outside React components, such as React Router loaders/actions, query callbacks, mutation handlers, and toast helpers, import the initialized i18next instance and use `i18n.t(...)`.

```ts
toast.error(i18n.t("app.auth.required"));
```

For rich text with links or components, keep the sentence in the locale file and use i18next/react-i18next interpolation instead of splitting the sentence into separate keys.

## Extraction And Checks

Run commands from `assets`:

```bash
bun i18next-cli lint
bun i18next-cli status
```

`bun i18next-cli lint` catches many hardcoded strings, but it is incomplete. Manually check:

- Toast messages in React Router loaders/actions. See `assets/js/routes/layout/index.tsx`.
- React Query callbacks and mutation flows. See `assets/js/routes/login/email-step.tsx`.
- Form labels, placeholders, input titles, aria labels, sr-only text, image alt text, menu items, empty states, errors, and success states.
- Non-component modules that cannot use `useTranslation`.

Before replacing apparent fallback text, check `references/reserved-locale-special-cases.md` for intentionally untranslated labels and locale-specific naming decisions.

Usually do not run `bun i18next-cli types` manually because precommit handles it. Run it when TypeScript reports stale i18n key types after locale edits.

## Quick Reference

| Situation | Action |
| --- | --- |
| Add page-only login text | Add under `auth.login.*` |
| Add app sidebar/nav text | Add under `app.nav.*` |
| Add reusable button/menu verb | Add under `app.actions.*` |
| Add unauthenticated redirect copy | Add under `app.auth.*` |
| Component copy | Use `useTranslation()` |
| Loader/action/toast copy | Use `i18n.t(...)` |
| After frontend changes | Check for hardcoded text and run i18next lint/status |

## Common Mistakes

- Localizing Phoenix backend templates or generated `priv/static` output. This project localizes only frontend `assets`.
- Adding English text directly in JSX, loaders, actions, toast calls, aria labels, or placeholders.
- Creating keys from the current sentence, which forces key churn when copy changes.
- Hiding feature copy in `app.*` when only one route owns it.
- Forgetting locale parity: every key added to English needs corresponding entries in every locale file, even if initially translated by tooling.
