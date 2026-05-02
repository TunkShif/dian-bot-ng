---
name: deciding-phoenix-contexts
description: Use when adding Phoenix features, schemas, migrations, external integrations, bot/webhook flows, schedulers, read models, or context APIs where the context boundary or data ownership is unclear
---

# Deciding Phoenix Contexts

## Overview

Choose Phoenix contexts by actor, reason to change, external system boundary, and data ownership. Treat the rules below as the complete working guidance before designing or changing a Phoenix context.

## When to Use

Use this before creating or changing Phoenix contexts, schemas, migrations, context APIs, bot ingestion flows, webhook handlers, scheduler jobs, external API clients, sync modules, or read models.

Do not use this for small implementation changes inside an already clear context boundary.

## Decision Order

1. Ask who the actor is: human, machine, scheduler, or external system.
2. Ask what independent reason would make this code change.
3. Put every external API, platform, webhook source, and delivery channel behind its own sync/client context.
4. Assign one source-of-truth owner for each table. Only that context writes that table.
5. Cross context boundaries with raw IDs and public APIs, not schema imports, associations, joins, or direct writes.
6. Split write paths from read paths when display/query needs would pollute canonical storage.
7. Use the microservice test: if this context moved out, callers should mostly keep using the same public API.

## Core Principles

**Actor first.** Different actors almost always mean different contexts: human users usually imply curation/management, machines and webhooks imply capture/integration, schedulers imply sync/monitoring, and external systems imply client/sync contexts.

**One reason to change.** If one module would change for two independent reasons, split the boundary. API response format changes, detection rule changes, and notification wording changes should not edit the same context.

**External integrations are separate.** Business logic never calls external APIs directly. A sync/client context owns HTTP details, auth, retries, caching, and raw response normalization, then exposes a clean public API such as `get_user/1` or `fetch_statuses/1`.

**One table writer.** Ask which context is the source of truth for each table. Only that context writes it; other contexts read through public APIs. If two contexts write the same table, merge them or clarify ownership before coding.

**IDs cross boundaries, structs do not.** Store raw IDs across contexts, not `belongs_to` associations to another context schema, schema aliases, or cross-context joins. Enrich data at read time in the context that owns the view.

```elixir
# Safe cross-context links
field :im_user_id, :string
field :owner_id, :integer

# Boundary violations
belongs_to :user, App.Accounts.User
alias App.Capture.Moment
```

**Write models and read models can differ.** Inbound/write contexts store lean canonical data such as raw sender IDs and payloads. Read contexts compose display structs or view models from multiple public APIs without turning those view models into DB schemas.

**Feature count is not context count.** A feature may add to an existing context, touch several contexts, or create a new one. Decide by domain boundary, actor, ownership, and reason to change.

**Context size is a smell, not a rule.** A small context is fine if it owns a real domain. A large context is fine if its functions are coherent. Split when functions feel unrelated or the context has too many independent reasons to change.

## Example Decisions

- Bot posts moments, human tags moments: separate `Capture` and `Curation` contexts because actors and write/read paths differ, even if both touch moment data.
- Add tags to moments: add schemas and APIs inside `Curation` because tags are a curation concern, not a new domain.
- Steam status monitor: split into contexts such as identity/binding, external sync, monitoring/detection, and bot notification because API fetching, polling rules, and delivery change independently.
- Search moments by keyword: add a read API to `Curation` if search is a curation/read concern and does not introduce a new owner.

## Quick Reference

| Signal | Decision |
| --- | --- |
| New external API, webhook source, or platform | New sync/client context |
| Different actor from existing flows | Likely new context |
| Different independent reason to change | Split or create a context |
| Same table needs writes from two contexts | Merge or clarify ownership |
| UI needs enriched cross-context data | Build a read model at query time |
| Need another context's data | Pass IDs and call public APIs |
| Same actor, same domain, same owner | Add to existing context |
| Context only wraps a mechanism, not a domain | Fold it into the owning domain |

## Required Output

When proposing or implementing context design, state:

- Actor for each flow.
- Context owner for each table.
- Which context writes each table.
- Public API calls used across boundaries.
- Whether the change is in a new context or an existing one, and why.

## Common Mistakes

- Treating every feature as a new context. Contexts follow domain boundaries, not feature count.
- Calling external APIs directly from business logic. Use a sync/client context.
- Importing another context's schema for associations or joins. Store IDs and enrich through public APIs.
- Letting display concerns reshape write schemas. Keep storage lean; compose read models separately.
- Splitting tiny mechanism contexts such as one-off email wrappers when they are not a domain.
