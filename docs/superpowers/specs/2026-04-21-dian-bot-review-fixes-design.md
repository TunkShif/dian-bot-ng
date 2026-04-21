# Dian Bot Review Fixes Design

## Purpose

Fix the issues found in the review of commit `fa53a1e` while keeping the scope narrow. The work should make `mix precommit` pass, provide a usable configurable test client, reduce stale response risk in `DianBot.Client.Default`, and add focused coverage for the new bot client and event behavior.

## Scope

This design covers:

- `DianBot.Client.Test` as a configurable in-process fake for tests.
- Timeout and cancellation cleanup inside `DianBot.Client.Default`.
- `DianBot.Event.build/1` timestamp population and safer payload access.
- Focused tests for the fake client, event building, and websocket client callback behavior where practical.

This design does not introduce a dedicated request broker or broad client architecture refactor. A broker-based design could centralize request ownership, timeout cleanup, and caller monitoring more strongly, but it changes the client boundary and should be handled separately if the bot integration grows.

## Test Client

`DianBot.Client.Test` should become a real fake implementation of the `DianBot.Client` behaviour. Tests will configure responses explicitly, and unstubbed actions will fail clearly instead of returning `nil`.

The test client should expose a small API similar to:

```elixir
DianBot.Client.Test.stub("get_group_list", fn params, opts ->
  {:ok, [%{"group_id" => 123, "group_name" => "test"}]}
end)
```

When production code calls `DianBot.Client.request/3`, the fake should look up the action and invoke the configured function with `params` and `opts`.

Default behavior for unstubbed actions should be:

```elixir
{:error, {:not_stubbed, action}}
```

The fake should use a supervised process, such as an Agent, for test-controlled state. Start it with `start_supervised!/1` in tests so cleanup is automatic. Because `DianBot.Client.request/3` does not pass a fake process name, the first implementation can use a single registered fake process and mark tests that mutate fake state as `async: false`. If async bot-client tests become important later, add explicit ownership or allowance support rather than relying on shared global stubs.

## Default Client Timeout Handling

Keep request lifecycle state inside `DianBot.Client.Default` for now. The goal is to prevent normal late responses from being forwarded to callers after a timeout and to remove cancelled pending entries.

The existing flow stores pending requests as request IDs mapped to caller information. Refine that pending entry so cancellation can verify the original request:

```elixir
%{
  request_id => {caller_pid, caller_ref}
}
```

On timeout, `request/3` should send a cancellation cast that includes both the request ID and caller ref:

```elixir
cast({:cancel_request, request_id, ref})
```

`handle_cast/2` should remove the pending entry only when the stored ref matches the cancellation ref. This avoids deleting a different request if IDs or messages are ever reused unexpectedly.

When a response arrives:

- If the request ID is pending, remove it and send exactly one response to the recorded caller.
- If the request ID is no longer pending because it timed out or was already handled, ignore the response.

This keeps the fix localized to `DianBot.Client.Default`. It does not fully eliminate every same-instant timeout/response race, but it makes normal late responses harmless and avoids stale pending state.

## Event Building

`DianBot.Event.build/1` should populate all advertised fields on `GroupMessageEvent`.

For group message payloads:

- `group_id` comes from `payload["group_id"]`.
- `sender_id` comes from `get_in(payload, ["sender", "user_id"])`.
- `message` comes from `payload["message"]`.
- `raw_message` comes from `payload["raw_message"]`.
- `timestamp` comes from `payload["time"]`.

Use `get_in/2` for nested sender access so a malformed or partial payload does not crash the websocket process. Unsupported payloads should continue returning `nil`.

Keep `timestamp` as the raw integer from the OneBot payload. There is no existing app-level time model for bot events yet, and preserving the API payload avoids guessing at timezone or conversion semantics.

## Tests

Add focused tests instead of broad integration tests.

### `DianBot.EventTest`

Cover:

- Builds a group message event with `group_id`, `sender_id`, `message`, `raw_message`, and `timestamp`.
- Returns `nil` for unsupported payloads.
- Does not crash when `"sender"` is missing; `sender_id` should be `nil`.

### `DianBot.Client.TestTest`

Cover:

- An unstubbed action returns `{:error, {:not_stubbed, action}}`.
- A stubbed action returns the configured response.
- The stub function receives both `params` and `opts`.
- State is isolated by starting the fake with `start_supervised!/1` in each test.

### `DianBot.Client.DefaultTest`

Cover callback-level behavior where practical:

- A successful response payload maps to `{:ok, data}` through the request flow or a tested helper.
- An error response returns `{:error, reason}` without `"data"` and `"echo"`.
- A cancellation removes the matching pending request.
- A late response for a cancelled request is ignored.

If private functions make direct assertions awkward, extract a small pure helper for response normalization. Avoid a large redesign just to improve testability.

## Verification

After implementation, run:

```bash
mix precommit
```

This should cover compilation with warnings as errors, unused dependency checks, formatting, and tests. The implementation is complete only when this command passes.

## Risks and Follow-Ups

The localized cancellation fix does not provide the same guarantee as a dedicated request broker using `GenServer.call` and centralized timeout ownership. If the bot client becomes a heavily used integration boundary, consider a follow-up design that introduces a broker process to own request IDs, timers, caller monitoring, websocket sends, and final replies.

The configurable fake should stay intentionally small. It should support bot-facing tests without becoming a parallel implementation of the real bot API.
