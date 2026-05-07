defmodule Dian.SteamWatcher.Notifier do
  use GenServer

  require Logger

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
    Logger.info("steam status event received",
      event: "steam_status_event_received",
      steam_id: event.steam_id,
      qq_id: event.qq_id,
      current_game_id: event.current_game_id,
      current_game_name: event.current_game_name
    )

    deliver.(event)
    {:noreply, state}
  end

  def notify(%StatusChanged{} = event) do
    group_ids = notification_targets(event)

    Logger.info("steam status notification start",
      event: "steam_status_notification_start",
      steam_id: event.steam_id,
      qq_id: event.qq_id,
      group_count: length(group_ids)
    )

    result =
      group_ids
      |> Enum.reduce_while({:ok, 0}, fn group_id, {:ok, count} ->
        case send_group_notification(group_id, event) do
          {:ok, :sent} -> {:cont, {:ok, count + 1}}
          {:ok, :skipped} -> {:cont, {:ok, count}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    Logger.info("steam status notification finished",
      event: "steam_status_notification_finished",
      steam_id: event.steam_id,
      qq_id: event.qq_id,
      result: inspect(result)
    )

    result
  end

  def build_status_card_svg(%StatusChanged{} = event) do
    player = steam_player_summary(event)
    merged_player = merge_event_game_name(player, event)

    Logger.info("steam status card render input",
      event: "steam_status_card_render_input",
      steam_id: event.steam_id,
      qq_id: event.qq_id,
      event_game_name: event.current_game_name || event.current_game_id,
      summary_game_name: player.playing_game_name,
      final_game_name: merged_player.playing_game_name,
      player_name: merged_player.name
    )

    StatusCard.build_status_card_svg(merged_player)
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

    Logger.info("steam status notification group start",
      event: "steam_status_notification_group_start",
      group_id: group_id,
      qq_id: qq_id,
      steam_id: event.steam_id
    )

    with {:ok, member} <- DianBot.get_group_member_info(group_id, qq_id, no_cache: true) do
      display_name = group_member_display_name(member, qq_id)
      svg = build_status_card_svg(event)

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
        Logger.info("steam status notification group sent",
          event: "steam_status_notification_group_sent",
          group_id: group_id,
          qq_id: qq_id,
          display_name: display_name
        )

        {:ok, :sent}
      else
        {:error, reason} ->
          Logger.warning("steam status notification group failed",
            event: "steam_status_notification_group_failed",
            group_id: group_id,
            qq_id: qq_id,
            reason: inspect(reason)
          )

          {:error, reason}
      end
    else
      {:error, :not_found} ->
        Logger.info("steam status notification group skipped",
          event: "steam_status_notification_group_skipped",
          group_id: group_id,
          qq_id: qq_id
        )

        {:ok, :skipped}

      {:error, reason} ->
        Logger.warning("steam status notification group failed",
          event: "steam_status_notification_group_failed",
          group_id: group_id,
          qq_id: qq_id,
          reason: inspect(reason)
        )

        {:error, reason}
    end
  end

  defp steam_player_summary(%StatusChanged{} = event) do
    Steam.get_player_summary(event.steam_id) ||
      %PlayerSummary{
        steam_id: event.steam_id,
        playing_game_name: event.current_game_name || event.current_game_id
      }
  end

  defp merge_event_game_name(%PlayerSummary{} = player, %StatusChanged{} = event) do
    case event.current_game_name || event.current_game_id do
      nil -> player
      game_name -> %{player | playing_game_name: game_name}
    end
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
