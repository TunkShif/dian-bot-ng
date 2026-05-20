defmodule DianBot.Commands.Handlers.SteamStatus do
  @moduledoc """
  Handles the `/steam:status` command — queries a user's Steam status.

  Requires the bot to be @-mentioned and a target user @-mentioned.

  ## Aliases

    * `/zgsm` — same as `/steam:status`

  ## Usage

      @bot /steam:status @user
  """

  use DianBot.Commands.Handler

  alias Dian.Steam

  @impl true
  def cmds do
    [
      %Entry{
        type: :immediate,
        module: __MODULE__,
        command: "steam:status",
        aliases: ["zgsm"],
        mention_required?: true,
        usage: "/steam:status @user"
      }
    ]
  end

  @impl true
  def parse_args(_raw_args, [%{type: "at", data: %{"qq" => qq}} | _]) do
    {:ok, to_string(qq)}
  end

  def parse_args(_raw_args, _extra_segments) do
    {:error, "请 @ 一个用户"}
  end

  @impl true
  def handle(%CommandRequest{}, qq_id) do
    case Steam.get_bound_player_summary_by_qq_id(qq_id) do
      {:ok, nil} ->
        {:reply, "未绑定 Steam 账号，请联系管理员绑定"}

      {:error, :steam_api_error} ->
        {:reply, "Steam API 查询失败，请稍后重试"}

      {:ok, summary} ->
        format_player_summary(summary, qq_id)
    end
  end

  defp format_player_summary(summary, qq_id) do
    msg =
      if summary.playing_game_name do
        "🎮 #{summary.name} 正在游玩 #{summary.playing_game_name}"
      else
        "💻 #{summary.name} 状态：#{state_label(summary.state)}"
      end

    {:reply, [DianBot.Message.at(qq_id), DianBot.Message.text(" #{msg}")]}
  end

  defp state_label(:offline), do: "⚫ 离线"
  defp state_label(:online), do: "🟢 在线"
  defp state_label(:busy), do: "🔴 忙碌"
  defp state_label(:away), do: "🟡 离开"
  defp state_label(:snooze), do: "💤 休眠"
  defp state_label(_), do: "❓ 未知"
end
