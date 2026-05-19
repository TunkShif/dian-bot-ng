# Bot Slash Command Handler Design

## Goal

Add a group-message slash command system for OneBot/NapCat events. Users invoke commands by sending group messages whose first meaningful command text starts with `/`. The system must support:

- Commands with optional or required arguments.
- Commands that require mentioning the bot account.
- Commands that require replying to another message.
- Stateless commands that execute immediately.
- Stateful batch workflows where multiple related command requests are accumulated and flushed by a submit command or by timeout.

The initial batch workflow is:

```text
[reply1] /append key1
[reply2] /append key1
[reply3] /append key2
/submit
```

Submitting groups pending reply ids by key for the same sender in the same group. With the example above, the workflow saves one thread for `key1` with `[reply1, reply2]` and another thread for `key2` with `[reply3]`. If the sender does not send `/submit` within 30 seconds after the latest append, the same submission runs automatically.

## Context Boundary

Actor: a human group-message user.

`DianBot` owns the external messaging-platform boundary: event normalization, slash-command parsing, command dispatch, temporary batch workflow state, and group-message replies through the OneBot client.

Domain contexts own command behavior. For example, the future thread-saving feature should live in a domain context such as `Dian.Threads`, not in `DianBot.Commands`. The command workflow should call a public domain API with raw ids, such as:

```elixir
Dian.Threads.create_from_group_replies(group_id, sender_id, grouped_reply_ids)
```

No new database tables are required for the command framework itself. If a domain command needs persistence, that domain context owns its tables and write APIs.

## Parsing Rules

Add `DianBot.Commands.Parser`, which accepts `%DianBot.Event.GroupMessageEvent{}` and the current bot id. It returns `{:ok, %DianBot.Commands.CommandRequest{}}` or `:ignore`.

Only recognize this shape:

```text
[optional reply segment] [optional @bot segment] [text segment starting with optional whitespace then "/" command]
```

The parser must ignore messages where `/` appears later in the message text. It must also ignore messages where any non-structural segment appears before the command text.

Recognized examples:

```text
/sj ces
@bot /cmd foo ba
[reply] /md quoted message
[reply] @bot /cmd foo ba
```

Ignored examples:

```text
hello /cmd
image /cmd
@someone_else /cmd
hello
```

The parser should use normalized message segments from `DianBot.Message`, not `raw_message`, because segment order distinguishes replies, mentions, and text reliably.

## Command Request

Add `DianBot.Commands.CommandRequest` as the normalized input passed to handlers and workflows:

```elixir
%DianBot.Commands.CommandRequest{
  group_id: group_id,
  sender_id: sender_id,
  message_id: message_id,
  timestamp: timestamp,
  name: "append",
  raw_args: "key1",
  args: nil,
  mentions_bot?: false,
  reply: %{message_id: "1289001822"} | nil,
  event: group_message_event,
  segments: segments
}
```

`reply` starts with the replied message id available in the OneBot reply segment. If a handler needs full quoted-message content, add a separate `DianBot.get_msg/2` wrapper later and call it from the domain behavior or workflow.

## Handler API

Add `DianBot.Commands.Handler` for stateless commands:

```elixir
@callback command() :: String.t()
@callback aliases() :: [String.t()]
@callback usage() :: String.t()
@callback mention_required?() :: boolean()
@callback reply_required?() :: boolean()
@callback parse_args(String.t()) :: {:ok, term()} | {:error, String.t()}
@callback handle(DianBot.Commands.CommandRequest.t(), parsed_args :: term()) ::
  {:reply, DianBot.message() | String.t()} | :noreply | {:error, String.t()}
```

The dispatcher applies generic checks in this order:

1. Parse a possible command.
2. Resolve the command name or alias through the registry.
3. Check `mention_required?/0`.
4. Check `reply_required?/0`.
5. Call `parse_args/1`.
6. Call `handle/2`.
7. Send a reply through `DianBot.send_msg(:group, group_id, response)` when the handler returns `{:reply, response}`.

Unknown commands should be ignored by default to avoid noisy group behavior. A future help command can list registered commands explicitly.

## Registry

Add `DianBot.Commands.Registry`, which maps command names and aliases to command modules. It should support two command categories:

- `:immediate` for stateless handlers.
- `:batch` for commands that collect entries into or flush a generic batch workflow.

The initial registry can be static module attributes. Runtime configuration can be added later if commands need deployment-specific enablement.

## Generic Batch Workflow

Add `DianBot.Commands.Batch`, a GenServer that stores temporary pending sessions for deferred command workflows.

Sessions are keyed by:

```elixir
{workflow_module, scope}
```

For group user workflows, the scope is:

```elixir
%{group_id: group_id, sender_id: sender_id}
```

This ensures `/submit` only submits pending entries from the same sender in the same group.

Session state stores:

```elixir
%{
  timer_ref: reference(),
  entries: [entry]
}
```

Every collected entry resets the workflow timeout. When the timer fires, the batch server flushes the session using the same code path as manual submit, with reason `:timeout`.

## Batch Workflow API

Add `DianBot.Commands.BatchWorkflow`:

```elixir
@callback workflow() :: atom()
@callback timeout_ms() :: pos_integer()
@callback scope(DianBot.Commands.CommandRequest.t()) :: term()
@callback collect(DianBot.Commands.CommandRequest.t(), parsed_args :: term()) ::
  {:ok, entry :: term()} | {:error, String.t()}
@callback flush(scope :: term(), entries :: [term()], reason :: :submit | :timeout) ::
  {:reply, DianBot.message() | String.t()} | :noreply | {:error, String.t()}
```

`Batch.collect(workflow_module, request, parsed_args)` should:

1. Build the scope with `workflow_module.scope(request)`.
2. Call `workflow_module.collect(request, parsed_args)`.
3. Append the returned entry to the session.
4. Reset the session timer to `workflow_module.timeout_ms()`.

`Batch.flush(workflow_module, request_or_scope, reason)` should:

1. Resolve the scope.
2. Remove the session.
3. Cancel its timer.
4. Call `workflow_module.flush(scope, entries, reason)`.

If no entries exist on manual submit, return a short usage or status reply.

## Initial Thread Append Workflow

Add a workflow module such as `DianBot.Commands.Workflows.ThreadAppend`.

Commands:

- `/append key`
- `/submit`

`/append key` requires a reply and one non-empty key argument. It collects:

```elixir
%{key: key, reply_message_id: reply_message_id}
```

`/submit` does not require a reply. It flushes `ThreadAppend` for the sender and group.

On flush, the workflow groups entries by key:

```elixir
%{
  "key1" => ["reply1", "reply2"],
  "key2" => ["reply3"]
}
```

It then calls the thread domain API once with the grouped reply ids. If the domain API is not implemented yet, introduce a narrow adapter module for this workflow, for example `DianBot.Commands.Workflows.ThreadAppend.Threads`, with one `create_from_group_replies/3` function. The adapter can return `{:error, :not_implemented}` until the domain context exists, but persistence must not be embedded in `DianBot.Commands`.

## Supervision

Start the following under the application supervisor when the bot client is enabled:

- `DianBot.Commands.Consumer`
- `DianBot.Commands.Batch`

The consumer subscribes to `DianBot.EventBus` in `init/1`. It handles `%DianBot.Event.GroupMessageEvent{}` messages and ignores other events.

`DianBot.Commands.Batch` should be independent from the consumer so batch timers survive consumer restarts. Pending batches are in-memory only; losing them on application restart is acceptable for the initial design because they are short-lived command sessions.

## Error Handling

Command validation errors should produce concise group replies:

- Missing required mention: ignore or reply depending on command policy. Default to ignore to avoid noise.
- Missing required reply: reply with handler usage.
- Missing or invalid args: reply with handler usage or parser-provided error.
- Manual `/submit` with no pending entries: reply that there is nothing to submit.
- Auto-submit failure: log with workflow, scope, and reason. Do not spam the group by default unless the workflow returns a user-facing reply.

Handler exceptions should not crash the WebSocket client. The consumer should catch command execution failures, log structured metadata, and optionally send a generic failure reply for manual commands.

## Testing

Add parser tests for:

- Plain `/cmd args`.
- `@bot /cmd args`.
- `[reply] /cmd args`.
- `[reply] @bot /cmd args`.
- Slash later in text is ignored.
- Non-structural segment before command text is ignored.
- Mention of a different user before command text is ignored.

Add dispatcher tests for:

- Unknown commands are ignored.
- Mention-required commands reject unmentioned requests.
- Reply-required commands reject unreplied requests.
- Valid commands receive parsed args and request metadata.

Add batch tests for:

- Entries are scoped by `{group_id, sender_id}`.
- Manual submit flushes only that sender and group.
- Appending resets the timer.
- Timeout flush uses the same workflow callback with reason `:timeout`.
- Entries are grouped by key in the thread append workflow.

Use `start_supervised!/1` for GenServers in tests. Avoid `Process.sleep/1`; use direct flush calls, short timer injection, `Process.monitor/1`, or `_ = :sys.get_state(pid)` to synchronize.
