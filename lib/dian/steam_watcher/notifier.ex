defmodule Dian.SteamWatcher.Notifier do
  use GenServer

  alias Dian.Media
  alias Dian.Settings
  alias Dian.Steam
  alias Dian.Steam.PlayerSummary
  alias Dian.SteamWatcher.Poller
  alias Dian.SteamWatcher.StatusCard
  alias Dian.SteamWatcher.StatusChanged
  alias DianBot.Message

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
    event
    |> notification_targets()
    |> Enum.reduce_while({:ok, 0}, fn group_id, {:ok, count} ->
      case send_group_notification(group_id, event) do
        {:ok, :sent} -> {:cont, {:ok, count + 1}}
        {:ok, :skipped} -> {:cont, {:ok, count}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  def format_message(%StatusChanged{} = event) do
    player = event.qq_id
    game = event.current_game_name || event.current_game_id || "a Steam game"

    "[CQ:at,qq=#{player}] is now playing #{game}"
  end

  def build_status_card_svg(player),
    do: StatusCard.build_status_card_svg(player)

  def build_status_card_svg(player, locale),
    do: StatusCard.build_status_card_svg(player, locale)

  defp notification_targets(%StatusChanged{}) do
    Settings.list_enabled_group_ids()
  end

  defp send_group_notification(group_id, %StatusChanged{} = event) do
    qq_id = event.qq_id

    with {:ok, member} <- DianBot.get_group_member_info(group_id, qq_id, no_cache: true) do
      display_name = group_member_display_name(member, qq_id)
      player = steam_player_summary(event)
      svg = StatusCard.build_status_card_svg(player)

      with {:ok, image} <- Media.render_svg(svg),
           {:ok, _message_id} <-
             DianBot.send_msg(
               :group,
               group_id,
               [
                 Message.text(
                   notification_text(
                     display_name,
                     event.current_game_name || event.current_game_id
                   )
                 ),
                 Message.image("base64://#{Base.encode64(image.bytes)}")
               ]
             ) do
        {:ok, :sent}
      else
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, :not_found} -> {:ok, :skipped}
      {:error, reason} -> {:error, reason}
    end
  end

  defp steam_player_summary(%StatusChanged{} = event) do
    Steam.get_player_summary(event.steam_id) ||
      %PlayerSummary{
        steam_id: event.steam_id,
        playing_game_name: event.current_game_name || event.current_game_id
      }
  end

  defp notification_text(display_name, game_name) do
    case notification_locale() do
      :zh -> "#{display_name} 正在游玩 #{game_name}"
      _ -> "#{display_name} is playing #{game_name}"
    end
  end

  defp group_member_display_name(member, qq_id) do
    normalize_label(member.display_name) ||
      normalize_label(member.nickname) ||
      qq_id
  end

  defp normalize_label(value) when is_binary(value) do
    value = String.trim(value)
    if value == "", do: nil, else: value
  end

  defp normalize_label(_), do: nil

  defp notification_locale do
    Application.get_env(:dian, :notification_locale, :en)
  end
end
