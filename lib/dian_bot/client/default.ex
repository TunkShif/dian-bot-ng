defmodule DianBot.Client.Default do
  use WebSockex

  require Logger

  alias DianBot.Event
  alias Phoenix.PubSub

  @env_key DianBot.Bot
  @behaviour DianBot.Client

  @default_timeout 5_000

  @pubsub Dian.PubSub
  @topic "bot:event"

  def start_link(_opts) do
    opts = Application.fetch_env!(:dian, @env_key)

    initial_state = %{pending: %{}}
    endpoint = Keyword.fetch!(opts, :endpoint)
    access_token = Keyword.fetch!(opts, :access_token)
    extra_headers = [{"Authorization", "Bearer #{access_token}"}]

    WebSockex.start_link(endpoint, __MODULE__, initial_state,
      name: __MODULE__,
      extra_headers: extra_headers
    )
  end

  defp cast(message) do
    WebSockex.cast(__MODULE__, message)
  end

  @impl true
  def request(action, params, opts) when is_list(opts) do
    timeout = Keyword.get(opts, :timeout, default_timeout())

    ref = make_ref()
    request_id = Ecto.UUID.generate()
    cast({:request, {self(), ref}, request_id, action, params})

    receive do
      {:response, ^ref, result} ->
        result
    after
      timeout ->
        cast({:cancel_request, request_id, ref})
        {:error, :timeout}
    end
  end

  @impl true
  def handle_frame({:text, msg}, state) do
    with {:ok, payload} <- Jason.decode(msg) do
      handle_message(payload, state)
    else
      {:error, reason} ->
        Logger.warning("ignored invalid websocket payload: #{inspect(reason)}")
        {:ok, state}
    end
  end

  @impl true
  def handle_cast({:request, caller, request_id, action, params}, state) do
    payload = %{
      "echo" => request_id,
      "action" => action,
      "params" => params
    }

    new_state = put_in(state.pending[request_id], caller)

    {:reply, {:text, Jason.encode!(payload)}, new_state}
  end

  def handle_cast({:cancel_request, echo, ref}, state) do
    pending =
      case Map.get(state.pending, echo) do
        {_pid, ^ref} -> Map.delete(state.pending, echo)
        _ -> state.pending
      end

    {:ok, %{state | pending: pending}}
  end

  defp handle_message(%{"post_type" => event_type} = payload, state) do
    if event = Event.build(payload) do
      PubSub.broadcast!(@pubsub, @topic, event)
    else
      Logger.info("ignored incoming #{event_type} event")
    end

    {:ok, state}
  end

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

  defp handle_message(payload, state) do
    Logger.debug("ignored incoming websocket payload: #{inspect(payload)}")
    {:ok, state}
  end

  defp default_timeout() do
    Application.fetch_env!(:dian, @env_key)
    |> Keyword.get(:timeout, @default_timeout)
  end

  defp response_result(%{"status" => "ok", "retcode" => 0} = payload) do
    {:ok, Map.get(payload, "data")}
  end

  defp response_result(payload) do
    {:error, Map.drop(payload, ["data", "echo"])}
  end
end
