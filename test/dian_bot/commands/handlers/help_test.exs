defmodule DianBot.Commands.Handlers.HelpTest do
  use ExUnit.Case, async: true

  alias DianBot.Commands.CommandRequest
  alias DianBot.Commands.Handlers.Help
  alias DianBot.Commands.Registry

  describe "cmds/0" do
    test "returns the help command entry" do
      [entry] = Help.cmds()
      assert entry.command == "help"
      assert entry.aliases == ["h"]
      assert entry.type == :immediate
    end
  end

  describe "parse_args/2" do
    test "accepts empty args" do
      assert Help.parse_args("", []) == {:ok, nil}
    end

    test "rejects non-empty args" do
      assert Help.parse_args("foo", []) == {:error, "no arguments expected"}
    end
  end

  describe "handle/2" do
    test "replies with usage for all registered commands" do
      entries = Registry.list_entries()

      result = Help.handle(%CommandRequest{}, nil)
      assert {:reply, reply} = result
      assert String.starts_with?(reply, "📋 可用命令")

      for entry <- entries do
        assert reply =~ entry.usage, "expected #{entry.usage} in help output"
      end
    end
  end
end
