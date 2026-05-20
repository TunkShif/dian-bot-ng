defmodule DianBot.Commands.Handlers.Help do
  @moduledoc """
  Handles the `/help` command — shows usage for all registered commands.

  ## Aliases

    * `/h` — same as `/help`

  ## Usage

      /help
  """

  use DianBot.Commands.Handler

  alias DianBot.Commands.Registry

  @impl true
  def cmds do
    [
      %Entry{
        type: :immediate,
        module: __MODULE__,
        command: "help",
        aliases: ["h"],
        usage: "/help"
      }
    ]
  end

  @impl true
  def parse_args("", _extra_segments), do: {:ok, nil}
  def parse_args(_other, _extra_segments), do: {:error, "no arguments expected"}

  @impl true
  def handle(%CommandRequest{}, nil) do
    lines =
      Registry.list_entries()
      |> Enum.map(&format_entry/1)

    {:reply, Enum.join(["📋 可用命令" | lines], "\n")}
  end

  defp format_entry(entry) do
    aliases =
      if entry.aliases != [] do
        " [" <> Enum.map_join(entry.aliases, "/", &("/" <> &1)) <> "]"
      else
        ""
      end

    "#{entry.usage}#{aliases}"
  end
end
