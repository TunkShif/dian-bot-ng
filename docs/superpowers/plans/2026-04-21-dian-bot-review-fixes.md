# Dian Bot Review Fixes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the DianBot review issues by adding a configurable test client, safer event building, localized request cancellation cleanup, and focused tests so `mix precommit` passes.

**Architecture:** Keep the production API as `DianBot.Client.request/3`. `DianBot.Client.Test` becomes a small Agent-backed fake for tests. `DianBot.Client.Default` continues to own websocket request state, with cancellation matching on both request ID and caller ref.

**Tech Stack:** Elixir, Phoenix, ExUnit, Agent, WebSockex callbacks, Jason, Phoenix.PubSub.

---

## File Structure

- Modify `lib/dian_bot/client/test.ex`: implement a configurable Agent-backed fake that satisfies `DianBot.Client`.
- Modify `lib/dian_bot/event.ex`: populate `timestamp` and use safe nested sender access.
- Modify `lib/dian_bot/client/default.ex`: include request ref in cancellation and ignore late responses for removed pending requests.
- Create `test/dian_bot/client/test_test.exs`: tests for the configurable fake.
- Create `test/dian_bot/event_test.exs`: tests for group message event building.
- Create `test/dian_bot/client/default_test.exs`: tests for WebSockex callback-level cancellation and response behavior.

## Task 1: Configurable Test Client

**Files:**
- Modify: `lib/dian_bot/client/test.ex`
- Create: `test/dian_bot/client/test_test.exs`

- [ ] **Step 1: Write failing tests for the fake client**

Create `test/dian_bot/client/test_test.exs`:

```elixir
defmodule DianBot.Client.TestTest do
  use ExUnit.Case, async: false

  alias DianBot.Client
  alias DianBot.Client.Test, as: TestClient

  setup do
    start_supervised!(TestClient)
    :ok
  end

  test "unstubbed actions return explicit error" do
    assert Client.request("missing_action", %{"page" => 1}, timeout: 10) ==
             {:error, {:not_stubbed, "missing_action"}}
  end

  test "stubbed action returns configured response" do
    TestClient.stub("get_group_list", fn params, opts ->
      assert params == %{"page" => 1}
      assert opts == [timeout: 10]
      {:ok, [%{"group_id" => 123, "group_name" => "test"}]}
    end)

    assert Client.get_group_list(%{"page" => 1}, timeout: 10) ==
             {:ok, [%{"group_id" => 123, "group_name" => "test"}]}
  end

  test "stubs are replaced for the same action" do
    TestClient.stub("get_group_list", fn _params, _opts -> {:ok, [:first]} end)
    TestClient.stub("get_group_list", fn _params, _opts -> {:ok, [:second]} end)

    assert Client.get_group_list(%{}) == {:ok, [:second]}
  end
end
```

- [ ] **Step 2: Run fake client tests and verify they fail**

Run:

```bash
mix test test/dian_bot/client/test_test.exs
```

Expected: FAIL because `DianBot.Client.Test` does not implement `start_link/1` or `stub/2`, and `request/3` returns `nil`.

- [ ] **Step 3: Implement the Agent-backed fake client**

Replace `lib/dian_bot/client/test.ex` with:

```elixir
defmodule DianBot.Client.Test do
  use Agent

  @behaviour DianBot.Client

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def stub(action, fun) when is_binary(action) and is_function(fun, 2) do
    Agent.update(__MODULE__, &Map.put(&1, action, fun))
  end

  @impl true
  def request(action, params, opts) do
    __MODULE__
    |> Agent.get(&Map.get(&1, action))
    |> case do
      nil -> {:error, {:not_stubbed, action}}
      fun -> fun.(params, opts)
    end
  end
end
```

- [ ] **Step 4: Run fake client tests and verify they pass**

Run:

```bash
mix test test/dian_bot/client/test_test.exs
```

Expected: PASS with 3 tests.

- [ ] **Step 5: Run compile warnings check for this task**

Run:

```bash
mix compile --warnings-as-errors
```

Expected: PASS. The unused variable warnings from `DianBot.Client.Test.request/3` should be gone.

- [ ] **Step 6: Commit Task 1**

Run:

```bash
git add lib/dian_bot/client/test.ex test/dian_bot/client/test_test.exs
git commit -m "test: add configurable DianBot test client"
```

## Task 2: Event Building Fixes

**Files:**
- Modify: `lib/dian_bot/event.ex`
- Create: `test/dian_bot/event_test.exs`

- [ ] **Step 1: Write failing tests for event building**

Create `test/dian_bot/event_test.exs`:

```elixir
defmodule DianBot.EventTest do
  use ExUnit.Case, async: true

  alias DianBot.Event
  alias DianBot.Event.GroupMessageEvent

  test "builds group message events with all advertised fields" do
    payload = %{
      "post_type" => "message",
      "message_type" => "group",
      "group_id" => 456,
      "sender" => %{"user_id" => 789},
      "message" => [%{"type" => "text", "data" => %{"text" => "hello"}}],
      "raw_message" => "hello",
      "time" => 1_713_456_789
    }

    assert Event.build(payload) == %GroupMessageEvent{
             group_id: 456,
             sender_id: 789,
             message: [%{"type" => "text", "data" => %{"text" => "hello"}}],
             raw_message: "hello",
             timestamp: 1_713_456_789
           }
  end

  test "returns nil for unsupported payloads" do
    assert Event.build(%{"post_type" => "notice", "notice_type" => "group_upload"}) == nil
  end

  test "does not crash when sender is missing" do
    payload = %{
      "post_type" => "message",
      "message_type" => "group",
      "group_id" => 456,
      "message" => [],
      "raw_message" => "",
      "time" => 1_713_456_789
    }

    assert %GroupMessageEvent{sender_id: nil, timestamp: 1_713_456_789} = Event.build(payload)
  end
end
```

- [ ] **Step 2: Run event tests and verify they fail**

Run:

```bash
mix test test/dian_bot/event_test.exs
```

Expected: FAIL because `timestamp` is not populated and missing `"sender"` access is unsafe.

- [ ] **Step 3: Implement safer event building**

Update `lib/dian_bot/event.ex`:

```elixir
defmodule DianBot.Event do
  defmodule GroupMessageEvent do
    defstruct [:group_id, :sender_id, :message, :raw_message, :timestamp]
  end

  def build(%{"post_type" => "message", "message_type" => "group"} = payload) do
    %GroupMessageEvent{
      group_id: payload["group_id"],
      sender_id: get_in(payload, ["sender", "user_id"]),
      message: payload["message"],
      raw_message: payload["raw_message"],
      timestamp: payload["time"]
    }
  end

  def build(_), do: nil
end
```

- [ ] **Step 4: Run event tests and verify they pass**

Run:

```bash
mix test test/dian_bot/event_test.exs
```

Expected: PASS with 3 tests.

- [ ] **Step 5: Commit Task 2**

Run:

```bash
git add lib/dian_bot/event.ex test/dian_bot/event_test.exs
git commit -m "fix: populate DianBot group message timestamp"
```

## Task 3: Default Client Cancellation and Response Behavior

**Files:**
- Modify: `lib/dian_bot/client/default.ex`
- Create: `test/dian_bot/client/default_test.exs`

- [ ] **Step 1: Write failing callback-level tests**

Create `test/dian_bot/client/default_test.exs`:

```elixir
defmodule DianBot.Client.DefaultTest do
  use ExUnit.Case, async: true

  alias DianBot.Client.Default

  test "successful response sends ok result and removes pending request" do
    ref = make_ref()
    request_id = "request-1"
    state = %{pending: %{request_id => {self(), ref}}}

    assert {:ok, %{pending: %{}}} =
             Default.handle_frame(
               {:text,
                Jason.encode!(%{
                  "echo" => request_id,
                  "status" => "ok",
                  "retcode" => 0,
                  "data" => %{"groups" => []}
                })},
               state
             )

    assert_receive {:response, ^ref, {:ok, %{"groups" => []}}}
  end

  test "error response drops data and echo before replying" do
    ref = make_ref()
    request_id = "request-1"
    state = %{pending: %{request_id => {self(), ref}}}

    assert {:ok, %{pending: %{}}} =
             Default.handle_frame(
               {:text,
                Jason.encode!(%{
                  "echo" => request_id,
                  "status" => "failed",
                  "retcode" => 1400,
                  "wording" => "bad request",
                  "data" => %{"ignored" => true}
                })},
               state
             )

    assert_receive {:response, ^ref, {:error, %{"retcode" => 1400, "status" => "failed", "wording" => "bad request"}}}
  end

  test "matching cancellation removes pending request" do
    ref = make_ref()
    request_id = "request-1"
    state = %{pending: %{request_id => {self(), ref}}}

    assert {:ok, %{pending: %{}}} =
             Default.handle_cast({:cancel_request, request_id, ref}, state)
  end

  test "cancellation with different ref keeps pending request" do
    ref = make_ref()
    other_ref = make_ref()
    request_id = "request-1"
    state = %{pending: %{request_id => {self(), ref}}}

    assert {:ok, ^state} =
             Default.handle_cast({:cancel_request, request_id, other_ref}, state)
  end

  test "late response for cancelled request is ignored" do
    ref = make_ref()
    state = %{pending: %{}}

    assert {:ok, %{pending: %{}}} =
             Default.handle_frame(
               {:text,
                Jason.encode!(%{
                  "echo" => "cancelled-request",
                  "status" => "ok",
                  "retcode" => 0,
                  "data" => %{"groups" => []}
                })},
               state
             )

    refute_receive {:response, ^ref, _result}
  end
end
```

- [ ] **Step 2: Run default client tests and verify they fail**

Run:

```bash
mix test test/dian_bot/client/default_test.exs
```

Expected: FAIL because `handle_cast/2` currently matches `{:cancel_request, request_id}` without the caller ref.

- [ ] **Step 3: Implement ref-matched cancellation**

Update `lib/dian_bot/client/default.ex` so timeout sends the ref:

```elixir
timeout ->
  cast({:cancel_request, request_id, ref})
  {:error, :timeout}
```

Replace the cancellation callback with:

```elixir
def handle_cast({:cancel_request, echo, ref}, state) do
  pending =
    case Map.get(state.pending, echo) do
      {_pid, ^ref} -> Map.delete(state.pending, echo)
      _ -> state.pending
    end

  {:ok, %{state | pending: pending}}
end
```

Keep response handling as:

```elixir
defp handle_message(%{"echo" => request_id} = payload, state) do
  {caller, pending} = Map.pop(state.pending, request_id)

  case caller do
    nil ->
      {:ok, state}

    {pid, ref} ->
      send(pid, {:response, ref, response_result(payload)})
      {:ok, %{state | pending: pending}}
  end
end
```

This already ignores late responses whose request IDs are no longer pending.

- [ ] **Step 4: Run default client tests and verify they pass**

Run:

```bash
mix test test/dian_bot/client/default_test.exs
```

Expected: PASS with 5 tests.

- [ ] **Step 5: Run all DianBot tests together**

Run:

```bash
mix test test/dian_bot
```

Expected: PASS for all DianBot-focused tests.

- [ ] **Step 6: Commit Task 3**

Run:

```bash
git add lib/dian_bot/client/default.ex test/dian_bot/client/default_test.exs
git commit -m "fix: match DianBot request cancellation by ref"
```

## Task 4: Final Verification

**Files:**
- Verify all changed files.

- [ ] **Step 1: Run formatter**

Run:

```bash
mix format
```

Expected: command exits 0. If formatting changes files, review `git diff`.

- [ ] **Step 2: Run precommit**

Run:

```bash
mix precommit
```

Expected: PASS. This covers `compile --warnings-as-errors`, `deps.unlock --unused`, `format`, and `test`.

- [ ] **Step 3: Review final diff**

Run:

```bash
git status --short
git diff --stat HEAD
git diff HEAD
```

Expected: only intentional implementation and test files are changed since the last task commit, or no changes if `mix format` did not modify anything after the task commits.

- [ ] **Step 4: Commit formatter changes when present**

When `git status --short` shows files changed by `mix format` after Task 3, run:

```bash
git add lib/dian_bot/client/test.ex lib/dian_bot/client/default.ex lib/dian_bot/event.ex test/dian_bot/client/test_test.exs test/dian_bot/client/default_test.exs test/dian_bot/event_test.exs
git commit -m "style: format DianBot review fixes"
```

Expected: a formatting-only commit. When `git status --short` is empty, skip this step because there are no formatter changes to commit.
