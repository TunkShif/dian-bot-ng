defmodule DianBot.Commands.Batch do
  @moduledoc """
  GenServer that stores temporary pending sessions for deferred batch workflows.

  Sessions are keyed by `{workflow_module, scope}` and auto-flushed after a
  workflow-defined inactivity timeout.
  """

  use GenServer
  require Logger

  alias DianBot.Commands.CommandRequest

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Validates and accumulates an entry for the given workflow and request.

  Delegates to `workflow.collect/2` for entry validation, then stores the
  entry and resets the inactivity timer.
  """
  @spec collect(module(), CommandRequest.t(), term()) :: :ok | {:error, String.t()}
  def collect(workflow_mod, request, parsed_args) do
    GenServer.call(__MODULE__, {:collect, workflow_mod, request, parsed_args})
  end

  @doc """
  Flushes all pending entries for the workflow and scope derived from the request.

  `reason` defaults to `:submit`. Pass `:timeout` for auto-flush.
  """
  @spec flush(module(), CommandRequest.t(), :submit | :timeout) ::
          {:reply, term()} | :noreply | {:error, :no_entries | String.t()}
  def flush(workflow_mod, request, reason \\ :submit) do
    GenServer.call(__MODULE__, {:flush, workflow_mod, request, reason})
  end

  @impl true
  def init(opts) do
    send_msg = Keyword.get(opts, :send_msg, &DianBot.send_msg/3)
    {:ok, %{sessions: %{}, send_msg: send_msg}}
  end

  @impl true
  def handle_call({:collect, workflow_mod, request, parsed_args}, _from, state) do
    scope = workflow_mod.scope(request)
    key = {workflow_mod, scope}

    case workflow_mod.collect(request, parsed_args) do
      {:ok, entry} ->
        {old_entries, sessions, timer_ref} =
          case state.sessions do
            %{^key => session} ->
              Process.cancel_timer(session.timer_ref)

              {session.entries, Map.delete(state.sessions, key),
               schedule_timer(key, workflow_mod)}

            _ ->
              {[], state.sessions, schedule_timer(key, workflow_mod)}
          end

        session = %{
          timer_ref: timer_ref,
          entries: [entry | old_entries],
          group_id: request.group_id
        }

        {:reply, :ok, %{state | sessions: Map.put(sessions, key, session)}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end

  def handle_call({:flush, workflow_mod, request, reason}, _from, state) do
    scope = workflow_mod.scope(request)
    key = {workflow_mod, scope}

    case state.sessions do
      %{^key => session} ->
        Process.cancel_timer(session.timer_ref)
        sessions = Map.delete(state.sessions, key)
        state = %{state | sessions: sessions}

        result =
          case workflow_mod.flush(scope, Enum.reverse(session.entries), reason) do
            {:reply, _msg} = reply -> reply
            other -> other
          end

        {:reply, result, state}

      %{} ->
        {:reply, {:error, :no_entries}, state}
    end
  end

  @impl true
  def handle_info({:flush_timeout, key = {workflow, scope}}, state) do
    case Map.pop(state.sessions, key, :not_found) do
      {:not_found, _} ->
        {:noreply, state}

      {%{entries: entries, group_id: group_id}, sessions} ->
        case workflow.flush(scope, Enum.reverse(entries), :timeout) do
          {:reply, msg} ->
            state.send_msg.(:group, group_id, msg)

          {:error, reason} ->
            Logger.warning([
              "batch auto-flush failed",
              workflow: inspect(workflow),
              scope: inspect(scope),
              reason: inspect(reason)
            ])

          :noreply ->
            :ok
        end

        {:noreply, %{state | sessions: sessions}}
    end
  end

  defp schedule_timer(key, workflow_mod) do
    Process.send_after(self(), {:flush_timeout, key}, workflow_mod.timeout_ms())
  end
end
