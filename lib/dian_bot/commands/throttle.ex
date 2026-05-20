defmodule DianBot.Commands.Throttle do
  @moduledoc """
  In-memory throttle store for immediate commands.

  Tracks command invocations by key and returns whether the caller is
  within a configured time window. Old entries are periodically evicted
  by a background sweep.
  """

  use GenServer

  @type key :: {integer(), integer() | nil, String.t(), non_neg_integer()}

  defmodule Policy do
    @moduledoc """
    Throttling policy for a command.

    Fields:
      * `window_ms` — time window in milliseconds. Repeated invocations
        within this window are throttled.
      * `on_throttled` — action when throttled: `:ignore` to silently
        drop, or `{:reply, message}` to send a reply to the group.
    """
    defstruct [:window_ms, :on_throttled]

    @type t :: %__MODULE__{
            window_ms: pos_integer(),
            on_throttled: :ignore | {:reply, String.t()}
          }
  end

  @doc """
  Checks whether `key` has been seen within `policy.window_ms`.

  Returns `:ok` if the invocation is allowed, or `{:throttled, response}`
  where `response` is the configured `on_throttled` action.
  """
  @spec check(key(), Policy.t()) :: :ok | {:throttled, :ignore | {:reply, String.t()}}
  def check(key, policy) do
    GenServer.call(__MODULE__, {:check, key, policy})
  end

  @doc false
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, %{entries: %{}, timer_ref: schedule_sweep()}}
  end

  @impl true
  def handle_call({:check, key, policy}, _from, state) do
    now = now_ms()

    case state.entries do
      %{^key => %{expires_at: expires_at}} when expires_at > now ->
        {:reply, {:throttled, policy.on_throttled}, state}

      _ ->
        expires_at = now + policy.window_ms
        {:reply, :ok, %{state | entries: Map.put(state.entries, key, %{expires_at: expires_at})}}
    end
  end

  @impl true
  def handle_info(:sweep, state) do
    now = now_ms()

    entries =
      Map.filter(state.entries, fn {_key, %{expires_at: expires_at}} ->
        expires_at > now
      end)

    {:noreply, %{state | entries: entries, timer_ref: schedule_sweep()}}
  end

  defp schedule_sweep do
    Process.send_after(self(), :sweep, :timer.minutes(5))
  end

  defp now_ms, do: System.system_time(:millisecond)
end
