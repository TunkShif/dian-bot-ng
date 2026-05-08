defmodule Dian.SteamWatcher.AchievementNotifier do
  use GenServer

  require Logger

  alias Dian.Settings
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
    |> Enum.reduce_while({:ok, 0}, fn group_id, {:ok, sent_count} ->
      case send_group_notification(group_id, event) do
        {:ok, :sent} -> {:cont, {:ok, sent_count + 1}}
        {:ok, :skipped} -> {:cont, {:ok, sent_count}}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp send_group_notification(group_id, %AchievementUnlocked{} = event) do
    with {:ok, member} <- DianBot.get_group_member_info(group_id, event.qq_id, no_cache: true),
         {:ok, _message_id} <-
           DianBot.send_msg(:group, group_id, [Message.text(notification_text(member, event))]) do
      {:ok, :sent}
    else
      {:error, :not_found} ->
        Logger.info("steam achievement notification group skipped",
          event: "steam_achievement_notification_group_skipped",
          group_id: group_id,
          qq_id: event.qq_id
        )

        {:ok, :skipped}

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

  defp notification_text(member, %AchievementUnlocked{} = event) do
    display_name =
      normalize_label(member.display_name) ||
        normalize_label(member.nickname) ||
        event.qq_id

    achievement_names =
      event.achievements
      |> Enum.map(&(&1.display_name || &1.api_name))
      |> Enum.join(achievement_separator())

    case Application.get_env(:dian, :notification_locale, :zh) do
      :zh -> "#{display_name} 在 #{event.game_name} 解锁了成就：#{achievement_names}"
      _ -> "#{display_name} unlocked achievements in #{event.game_name}: #{achievement_names}"
    end
  end

  defp normalize_label(value) when is_binary(value) do
    value = String.trim(value)
    if value == "", do: nil, else: value
  end

  defp normalize_label(_), do: nil

  defp achievement_separator do
    case notification_locale() do
      :zh -> "、"
      _ -> ", "
    end
  end

  defp notification_locale do
    Application.get_env(:dian, :notification_locale, :zh)
  end
end
