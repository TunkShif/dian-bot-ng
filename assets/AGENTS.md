# Frontend Agent Instructions

These instructions apply to the `assets` frontend workspace. Currently we have no testing infrastructure for the frontend, so skip testing for frontend.

## Tooling

- Use `bun` for package management and frontend command execution.
- Prefer `bun add`, `bun remove`, `bun install`, and `bun run <script>` over equivalent `npm`, `pnpm`, or `yarn` commands.

## Icons

- Use `@phosphor-icons/react` for icon components.
- Import icons with the `XXXIcon` component names.
- Good: `import { FingerprintIcon } from "@phosphor-icons/react"`
- Bad: `import { Fingerprint } from "@phosphor-icons/react"` because the non-`Icon` names are deprecated.

## Generated API Client

- Auto-generated OpenAPI-based API actions, Zod schemas, and TanStack Query integrations live under `js/client`.
- Treat generated client files as generated output. Prefer regenerating them through the project workflow instead of hand-editing them unless the task explicitly requires a targeted generated-file patch.

## Forms

- Build form components with TanStack Form, Zod, and TanStack Query mutations.
- Use Zod schemas for validation and TanStack Query mutations for submit side effects.
- In React 19, do not type submit handlers with `FormEvent<T>`; it is deprecated. Use `SubmitEvent<HTMLFormElement>` instead.
- Refer to `add-passkey-dialog.tsx` as the example pattern for form structure, validation, mutation handling, and UI composition.

## Routes

- Organize route modules using flattened route names.
- Example: route `/settings/user` should be implemented as `routes/settings.user`.
- Each route folder owns its domain-specific components, hooks, utilities, and related files.
- In a route `index.tsx`, export `loader` when needed and always export `Component`.
- Lazy-load route modules from `router.tsx`.

## Shared Code

- Put common libraries and reusable helpers in `js/lib/`.
- Put common reusable components in `js/components/`.
- Shadcn UI primitives live in `js/components/ui/`.
- Usually do not change files in `js/components/ui/`; prefer composing those primitives from feature or shared components instead.

## TanStack Query Conventions

- Prefer the auto-generated TanStack Query helpers from `js/client/@tanstack/react-query.gen` for query options, mutation options, and query keys.
- Use generated `...Options()` helpers with `useQuery`, and generated `...Mutation()` helpers with `useMutation`.
- Use generated `...QueryKey()` helpers for cache invalidation. Do not rely on handwritten query keys or internal generated key structure.
- Prefer mutation `meta` (see `js/lib/query-client.ts`) for success/error toasts and query invalidation when the behavior is static.
- Use `onSuccess`, `onError`, or `onSettled` callbacks when invalidation or side effects depend on runtime mutation variables or require more flexible control flow.
- For route-level query UIs, follow the existing pattern used in groups and passkeys:
  - extract dedicated loading state components
  - extract dedicated error state components with retry where appropriate
  - extract dedicated empty state components when applicable
  - keep the main section/page component focused on selecting between loading, error, empty, and success states
