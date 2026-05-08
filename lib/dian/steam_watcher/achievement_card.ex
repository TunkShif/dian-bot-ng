defmodule Dian.SteamWatcher.AchievementCard do
  @moduledoc """
  Builds Steam achievement card SVG output for the Steam watcher.
  """

  alias Dian.SteamWatcher.AchievementUnlocked

  @card_width 920
  @card_height 240
  @icon_size 160
  @icon_x 28
  @icon_y 40
  @text_x 228
  @line1_y 92
  @line2_y 138
  @line3_y 186
  @bg_start "#0b1117"
  @bg_end "#171a21"
  @text_primary "#f5f7fa"
  @text_secondary "#aeb9c8"
  @accent "#d4af37"
  @border_color "rgba(255,255,255,0.08)"

  def build_achievement_card_svg(
        steam_user_name,
        game_name,
        %AchievementUnlocked.Item{} = achievement
      ) do
    steam_user_name = steam_user_name || locale_player_name(notification_locale())
    game_name = game_name || locale_game_name(notification_locale())
    achievement_name = achievement.display_name || achievement.api_name
    icon_href = icon_data_uri(achievement.icon_url)

    """
    <svg xmlns="http://www.w3.org/2000/svg" width="#{@card_width}" height="#{@card_height}" viewBox="0 0 #{@card_width} #{@card_height}">
      <defs>
        <linearGradient id="achievement-card-bg" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#{@bg_start}" />
          <stop offset="100%" stop-color="#{@bg_end}" />
        </linearGradient>
        <radialGradient id="achievement-glow" cx="18%" cy="22%" r="80%">
          <stop offset="0%" stop-color="#{@accent}" stop-opacity="0.16" />
          <stop offset="60%" stop-color="#{@accent}" stop-opacity="0.05" />
          <stop offset="100%" stop-color="#{@accent}" stop-opacity="0" />
        </radialGradient>
        <clipPath id="achievement-icon-clip">
          <rect x="#{@icon_x}" y="#{@icon_y}" width="#{@icon_size}" height="#{@icon_size}" rx="20" />
        </clipPath>
      </defs>
      <rect x="0" y="0" width="#{@card_width}" height="#{@card_height}" rx="24" fill="url(#achievement-card-bg)" />
      <rect x="0" y="0" width="#{@card_width}" height="#{@card_height}" rx="24" fill="url(#achievement-glow)" />
      <rect x="0" y="0" width="14" height="#{@card_height}" rx="7" fill="#{@accent}" />
      <image
        href="#{escape_svg(icon_href)}"
        x="#{@icon_x}"
        y="#{@icon_y}"
        width="#{@icon_size}"
        height="#{@icon_size}"
        preserveAspectRatio="xMidYMid slice"
        clip-path="url(#achievement-icon-clip)"
      />
      <rect
        x="#{@icon_x}"
        y="#{@icon_y}"
        width="#{@icon_size}"
        height="#{@icon_size}"
        rx="20"
        fill="none"
        stroke="#{@border_color}"
        stroke-width="1"
      />
      <text
        x="#{@text_x}"
        y="#{@line1_y}"
        fill="#{@text_primary}"
        font-family="WenQuanYi Micro Hei, Inter, sans-serif"
        font-size="42"
        font-weight="700"
      >#{escape_svg(steam_user_name)}</text>
      <text
        x="#{@text_x}"
        y="#{@line2_y}"
        fill="#{@text_secondary}"
        font-family="WenQuanYi Micro Hei, Inter, sans-serif"
        font-size="24"
        font-weight="400"
      >#{escape_svg(locale_subtitle(notification_locale(), game_name))}</text>
      <text
        x="#{@text_x}"
        y="#{@line3_y}"
        fill="#{@text_primary}"
        font-family="WenQuanYi Micro Hei, Inter, sans-serif"
        font-size="34"
        font-weight="600"
      >#{escape_svg(achievement_name)}</text>
    </svg>
    """
  end

  defp notification_locale do
    Application.get_env(:dian, :notification_locale, :zh)
  end

  defp locale_subtitle(:zh, game_name), do: "在 #{game_name} 中取得了成就"
  defp locale_subtitle(_locale, game_name), do: "unlocked an achievement in #{game_name}"

  defp locale_game_name(:zh), do: "一款 Steam 游戏"
  defp locale_game_name(_locale), do: "a Steam game"

  defp locale_player_name(:zh), do: "Steam 玩家"
  defp locale_player_name(_locale), do: "Steam player"

  defp icon_data_uri(nil), do: transparent_icon_data_uri()
  defp icon_data_uri(""), do: transparent_icon_data_uri()

  defp icon_data_uri(url) when is_binary(url) do
    case icon_fetcher().(url) do
      {:ok, data_uri} when is_binary(data_uri) ->
        if String.starts_with?(data_uri, "data:") do
          data_uri
        else
          "data:image/jpeg;base64," <> Base.encode64(data_uri)
        end

      {:ok, %Req.Response{status: 200, body: body}} when is_binary(body) ->
        "data:image/jpeg;base64," <> Base.encode64(body)

      {:ok, body} when is_binary(body) ->
        "data:image/jpeg;base64," <> Base.encode64(body)

      _ ->
        transparent_icon_data_uri()
    end
  end

  defp icon_fetcher do
    Application.get_env(:dian, :steam_achievement_icon_fetcher, &default_icon_fetcher/1)
  end

  defp default_icon_fetcher(url) do
    case Req.get(url: url, retry: false, receive_timeout: 5_000) do
      {:ok, %Req.Response{status: 200, body: body}} when is_binary(body) ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:achievement_icon_request_failed, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp transparent_icon_data_uri do
    "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxIiBoZWlnaHQ9IjEiLz4="
  end

  defp escape_svg(value) when is_binary(value) do
    value
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end

  defp escape_svg(value), do: escape_svg(to_string(value))
end
