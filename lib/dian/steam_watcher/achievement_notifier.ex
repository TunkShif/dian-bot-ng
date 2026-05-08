defmodule Dian.SteamWatcher.AchievementNotifier do
  use GenServer

  require Logger

  alias Dian.Media
  alias Dian.Settings
  alias Dian.Steam
  alias Dian.Steam.PlayerSummary
  alias Dian.SteamWatcher.AchievementCard
  alias Dian.SteamWatcher.AchievementPoller
  alias Dian.SteamWatcher.AchievementUnlocked
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
      AchievementPoller.subscribe()
    end

    {:ok, %{deliver: Keyword.get(opts, :deliver, &notify/1)}}
  end

  @impl true
  def handle_info(%AchievementUnlocked{} = event, %{deliver: deliver} = state) do
    deliver.(event)
    {:noreply, state}
  end

  def notify(%AchievementUnlocked{} = event) do
    group_ids = Settings.list_enabled_group_ids()

    group_ids
    |> Enum.reduce({:ok, 0}, fn group_id, {:ok, sent_count} ->
      case send_group_notification(group_id, event) do
        {:ok, count} -> {:ok, sent_count + count}
        {:error, _reason} -> {:ok, sent_count}
      end
    end)
  end

  def build_achievement_card_svg(%AchievementUnlocked{} = event) do
    player = steam_player_summary(event)
    achievement = representative_achievement(event)

    AchievementCard.build_achievement_card_svg(
      player.name,
      event.game_name,
      achievement
    )
  end

  defp send_group_notification(group_id, %AchievementUnlocked{} = event) do
    with {:ok, member} <- DianBot.get_group_member_info(group_id, event.qq_id, no_cache: true) do
      display_name = group_member_display_name(member, event.qq_id)
      player = steam_player_summary(event)

      event
      |> notification_payloads(display_name, player)
      |> Enum.reduce_while({:ok, 0}, fn payload, {:ok, count} ->
        case send_payload(group_id, payload) do
          {:ok, _message_id} -> {:cont, {:ok, count + 1}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    else
      {:error, :not_found} ->
        Logger.info("steam achievement notification group skipped",
          event: "steam_achievement_notification_group_skipped",
          group_id: group_id,
          qq_id: event.qq_id
        )

        {:ok, 0}

      {:error, reason} ->
        Logger.warning("steam achievement notification group failed",
          event: "steam_achievement_notification_group_failed",
          group_id: group_id,
          qq_id: event.qq_id,
          reason: inspect(reason)
        )

        {:error, reason}
    end
  end

  defp notification_payloads(
         %AchievementUnlocked{achievements: achievements} = event,
         display_name,
         player
       ) do
    if length(achievements) >= 3 do
      [notification_payload(event, display_name, player, achievements)]
    else
      Enum.map(achievements, fn achievement ->
        notification_payload(%{event | achievements: [achievement]}, display_name, player, [
          achievement
        ])
      end)
    end
  end

  defp notification_payload(
         %AchievementUnlocked{} = event,
         display_name,
         %PlayerSummary{} = player,
         achievements
       ) do
    svg =
      AchievementCard.build_achievement_card_svg(
        player.name,
        event.game_name,
        hd(achievements)
      )

    achievement_names =
      achievements
      |> Enum.map(&(&1.display_name || &1.api_name))
      |> Enum.join(achievement_separator())

    {:ok, image} = Media.render_svg(svg)

    [
      Message.text(notification_text(display_name, event.game_name, achievement_names)),
      Message.image("base64://#{Base.encode64(image.bytes)}")
    ]
  end

  defp send_payload(group_id, payload) do
    DianBot.send_msg(:group, group_id, payload)
  end

  defp notification_text(display_name, game_name, achievement_names) do
    case notification_locale() do
      :zh -> "#{display_name} 在 #{game_name} 中取得了成就：#{achievement_names}！"
      _ -> "#{display_name} unlocked achievements in #{game_name}: #{achievement_names}!"
    end
  end

  defp steam_player_summary(%AchievementUnlocked{} = event) do
    Steam.get_player_summary(event.steam_id) ||
      %PlayerSummary{
        steam_id: event.steam_id
      }
  end

  defp representative_achievement(%AchievementUnlocked{achievements: [achievement | _rest]}),
    do: achievement

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

  defp achievement_separator do
    case notification_locale() do
      :zh -> ","
      _ -> ", "
    end
  end

  defp notification_locale do
    Application.get_env(:dian, :notification_locale, :zh)
  end
end
