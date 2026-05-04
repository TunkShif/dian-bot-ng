defmodule Dian.SteamWatcher.Notifier do
  use GenServer

  alias Dian.SteamWatcher.Poller
  alias Dian.SteamWatcher.StatusChanged

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    genserver_opts = if name, do: [name: name], else: []

    GenServer.start_link(__MODULE__, opts, genserver_opts)
  end

  @impl true
  def init(opts) do
    subscribe? = Keyword.get(opts, :subscribe?, true)

    if subscribe? do
      Poller.subscribe()
    end

    {:ok, %{deliver: Keyword.get(opts, :deliver, &notify/1)}}
  end

  @impl true
  def handle_info(%StatusChanged{} = event, %{deliver: deliver} = state) do
    deliver.(event)
    {:noreply, state}
  end

  def notify(%StatusChanged{} = event) do
    message = format_message(event)

    # TODO: Add Dian.Settings.list_steam_notification_enabled_group_ids/0,
    # filter enabled groups through DianBot.find_group_member_in_groups/2,
    # then send the formatted message through the bot group-message API.
    {:ok, message}
  end

  def format_message(%StatusChanged{} = event) do
    player = event.qq_id
    game = event.current_game_name || event.current_game_id || "a Steam game"

    "[CQ:at,qq=#{player}] is now playing #{game}"
  end
end
