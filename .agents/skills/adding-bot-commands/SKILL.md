---
name: adding-bot-commands
description: Use when implementing new slash commands (`:immediate`) or batch workflows (`:batch_collect`/`:batch_flush`) for the DianBot command framework
---

# Adding Bot Commands

## Overview

Each handler module declares its own command metadata via `cmds/0`, which returns
a list of `%Entry{}` structs. The Registry collects these at compile time from an
`@handlers` list and builds the name-to-entry lookup map automatically.

The `use` macro provides `CommandRequest`, `Entry`, and `Policy` aliases
automatically — no explicit aliasing needed.

## When to Use

Add a new handler/workflow module when creating:
- **Stateless commands** that reply immediately (e.g. `/help`, `/ping`, `/weather`)
- **Batch workflows** that accumulate entries then flush (e.g. `/note` + `/notes`)

Choose `:immediate` for one-shot replies. Choose `:batch` when you need to
collect multiple inputs before processing (polls, sequential notes, multi-step).

**When NOT to use this skill:** Modifying an existing command, fixing a handler
bug, or changing dispatch logic — read/explore the existing module instead.

## Creating an Immediate Command

### 1. Handler module

```elixir
# lib/dian_bot/commands/handlers/help_handler.ex
defmodule DianBot.Commands.Handlers.HelpHandler do
  use DianBot.Commands.Handler

  @impl true
  def cmds do
    [%Entry{
      type: :immediate,
      module: __MODULE__,
      command: "help",
      aliases: ["h"],
      mention_required?: false,
      reply_required?: false,
      usage: "/help [topic]"
    }]
  end

  @impl true
  def parse_args(""), do: {:ok, nil}
  def parse_args(args), do: {:ok, args}

  @impl true
  def handle(_request, _parsed), do: {:reply, "Available commands: ..."}
end
```

### 2. Register in `@handlers`

Add your module to the `@handlers` list in `lib/dian_bot/commands/registry.ex`:

```elixir
@handlers [
  DianBot.Commands.Handlers.Ping,
  DianBot.Commands.Handlers.Weather,
  DianBot.Commands.Handlers.Note,
  DianBot.Commands.Handlers.HelpHandler   # <-- add here
]
```

Aliases are declared in `cmds/0` via the `aliases` field — no separate entry needed.

### 3. Throttling (optional)

Add a `throttle` field to the entry. `Policy` is auto-aliased from `use`:

```elixir
%Entry{type: :immediate, module: __MODULE__, command: "poll", usage: "/poll <q>",
       throttle: %Policy{window_ms: 30_000, on_throttled: {:reply, "slow down!"}}}
```

### 4. Unit tests

```elixir
# test/dian_bot/commands/handlers/help_handler_test.exs
defmodule DianBot.Commands.Handlers.HelpHandlerTest do
  use ExUnit.Case, async: true
  alias DianBot.Commands.Handlers.HelpHandler

  test "cmds/0" do
    [entry] = HelpHandler.cmds()
    assert entry.command == "help"
    assert entry.aliases == ["h"]
  end
  test "parse_args/1" do ... end
  test "handle/2" do ... end
end
```

## Creating a Batch Workflow

### 1. Workflow module

```elixir
# lib/dian_bot/commands/handlers/poll_workflow.ex
defmodule DianBot.Commands.Handlers.PollWorkflow do
  use DianBot.Commands.BatchWorkflow

  @impl true
  def cmds do
    [
      %Entry{type: :batch_collect, module: __MODULE__, command: "poll",
             aliases: [], usage: "/poll <opt>"},
      %Entry{type: :batch_flush,   module: __MODULE__, command: "endpoll",
             aliases: [], usage: "/endpoll"}
    ]
  end

  @impl true
  def workflow, do: :poll
  @impl true
  def timeout_ms, do: :timer.minutes(30)
  @impl true
  def scope(%CommandRequest{} = req), do: %{group_id: req.group_id, sender_id: req.sender_id}
  @impl true
  def parse_args(args), do: {:ok, args}
  @impl true
  def collect(_request, args), do: {:ok, args}
  @impl true
  def flush(_scope, entries, _reason), do: {:reply, "...#{length(entries)} entries"}
end
```

### 2. Register in `@handlers`

Same as immediate — add the module to `@handlers`. One registration covers
both collect and flush.

## Registry Entry Reference

| Field | Required | Description |
|-------|----------|-------------|
| `:type` | yes | `:immediate \| :batch_collect \| :batch_flush` |
| `:module` | yes | The handler/workflow module |
| `:command` | yes | Primary command name (without `/`) |
| `:aliases` | yes | Alternative names (empty list `[]` if none) |
| `:usage` | yes | Shown on invalid invocation |
| `:mention_required?` | no | Bot @-mention required (default `false`) |
| `:reply_required?` | no | Reply required (default `false`) |
| `:throttle` | no | `%Policy{...}` for rate-limiting (immediate only) |

## Reply Types

| Return | Effect |
|--------|--------|
| `{:reply, msg}` | Sends `msg` (string, segment map, or segment list) to the group |
| `:noreply` | Silent — no group message |
| `{:error, reason}` | Sends `"Error: #{reason}"` |
| `{:error, :no_entries}` | Batch flush only — sends `"nothing to submit"` |

## Common Mistakes

- **Validation placement**: `parse_args/1` runs for both collect and flush. Put
  content validation in `collect/2`, not `parse_args/1`.
- **Don't forget `@handlers`**: Creating a handler with `cmds/0` is not enough —
  the module must be listed in the Registry's `@handlers` list.
- **Don't add explicit aliases**: `CommandRequest`, `Entry`, and `Policy` are
  auto-aliased by `use` — redundant aliases are noise.
- **Throttle is immediate-only**: The `:throttle` field is ignored for batch types.
- **Update registry tests**: Adding handlers changes `Registry.commands/0` output
  — update `registry_test.exs` to expect the new command names.
- **Scope isolation**: Use `%{group_id: req.group_id, sender_id: req.sender_id}` for
  per-user-per-group sessions. Omitting `sender_id` shares across all group users.
