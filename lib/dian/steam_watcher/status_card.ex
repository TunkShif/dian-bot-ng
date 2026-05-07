defmodule Dian.SteamWatcher.StatusCard do
  @moduledoc """
  Builds Steam player status card SVG output for the Steam watcher.
  """

  alias Dian.Steam.PlayerSummary

  @card_width 920
  @card_height 240
  @avatar_size 160
  @avatar_x 28
  @avatar_y 40
  @text_x 228
  @line1_y 96
  @line2_y 138
  @line3_y 188
  @bg_start "#0b1117"
  @bg_end "#171a21"
  @text_primary "#f5f7fa"
  @text_secondary "#aeb9c8"
  @border_color "rgba(255,255,255,0.08)"

  @doc """
  Builds the SVG for a Steam player status card.

  The default locale comes from `:notification_locale`.
  """
  def build_status_card_svg(%PlayerSummary{} = player),
    do: build_status_card_svg(player, notification_locale())

  def build_status_card_svg(%PlayerSummary{} = player, locale) do
    player_name = player.name || locale_player_name(locale)
    game_name = player.playing_game_name || locale_game_name(locale)
    playing_text = locale_playing_text(locale)
    avatar_href = avatar_data_uri(player.avatar_url)
    status_bar_color = state_color(player.state)

    """
    <svg xmlns="http://www.w3.org/2000/svg" width="#{@card_width}" height="#{@card_height}" viewBox="0 0 #{@card_width} #{@card_height}">
      <defs>
        <linearGradient id="card-bg" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" stop-color="#{@bg_start}" />
          <stop offset="100%" stop-color="#{@bg_end}" />
        </linearGradient>
        <radialGradient id="glow" cx="18%" cy="22%" r="80%">
          <stop offset="0%" stop-color="#66c0f4" stop-opacity="0.18" />
          <stop offset="60%" stop-color="#66c0f4" stop-opacity="0.04" />
          <stop offset="100%" stop-color="#66c0f4" stop-opacity="0" />
        </radialGradient>
        <clipPath id="avatar-clip">
          <rect x="#{@avatar_x}" y="#{@avatar_y}" width="#{@avatar_size}" height="#{@avatar_size}" />
        </clipPath>
      </defs>
      <rect x="0" y="0" width="#{@card_width}" height="#{@card_height}" rx="24" fill="url(#card-bg)" />
      <rect x="0" y="0" width="#{@card_width}" height="#{@card_height}" rx="24" fill="url(#glow)" />
      <rect x="0" y="0" width="14" height="#{@card_height}" rx="7" fill="#{status_bar_color}" />
      <image
        href="#{escape_svg(avatar_href)}"
        x="#{@avatar_x}"
        y="#{@avatar_y}"
        width="#{@avatar_size}"
        height="#{@avatar_size}"
        preserveAspectRatio="xMidYMid slice"
        clip-path="url(#avatar-clip)"
      />
      <rect
        x="#{@avatar_x}"
        y="#{@avatar_y}"
        width="#{@avatar_size}"
        height="#{@avatar_size}"
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
      >#{escape_svg(player_name)}</text>
      <text
        x="#{@text_x}"
        y="#{@line2_y}"
        fill="#{@text_secondary}"
        font-family="WenQuanYi Micro Hei, Inter, sans-serif"
        font-size="24"
        font-weight="400"
      >#{escape_svg(playing_text)}</text>
      <text
        x="#{@text_x}"
        y="#{@line3_y}"
        fill="#{@text_primary}"
        font-family="WenQuanYi Micro Hei, Inter, sans-serif"
        font-size="34"
        font-weight="600"
      >#{escape_svg(game_name)}</text>
    </svg>
    """
  end

  defp notification_locale do
    Application.get_env(:dian, :notification_locale, :en)
  end

  defp locale_playing_text(:zh), do: "正在游玩"
  defp locale_playing_text(_locale), do: "is playing"

  defp locale_game_name(:zh), do: "一款 Steam 游戏"
  defp locale_game_name(_locale), do: "a Steam game"

  defp locale_player_name(:zh), do: "Steam 玩家"
  defp locale_player_name(_locale), do: "Steam player"

  defp state_color(:online), do: "#66c0f4"
  defp state_color(:busy), do: "#e46c5a"
  defp state_color(:away), do: "#f0b84b"
  defp state_color(:snooze), do: "#8c7bd8"
  defp state_color(:offline), do: "#49515e"
  defp state_color(_), do: "#66c0f4"

  defp avatar_data_uri(nil), do: transparent_avatar_data_uri()
  defp avatar_data_uri(""), do: transparent_avatar_data_uri()

  defp avatar_data_uri(url) when is_binary(url) do
    case avatar_fetcher().(url) do
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
        transparent_avatar_data_uri()
    end
  end

  defp avatar_fetcher do
    Application.get_env(:dian, :steam_avatar_fetcher, &default_avatar_fetcher/1)
  end

  defp default_avatar_fetcher(url) do
    case Req.get(url: url, retry: false, receive_timeout: 5_000) do
      {:ok, %Req.Response{status: 200, body: body}} when is_binary(body) ->
        {:ok, body}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:avatar_request_failed, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp transparent_avatar_data_uri do
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
