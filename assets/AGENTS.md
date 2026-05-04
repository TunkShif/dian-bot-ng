# Frontend Agent Instructions

These instructions apply to the `assets` frontend workspace.

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
- TanStack Query mutation success/error toasts and query invalidation are managed globally through mutation `meta`. Check `js/lib/query-client.ts` for the registered `mutationMeta` type before adding local toast or invalidation handling.
