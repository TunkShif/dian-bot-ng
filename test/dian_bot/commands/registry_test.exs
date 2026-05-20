defmodule DianBot.Commands.RegistryTest do
  use ExUnit.Case, async: true

  alias DianBot.Commands.Registry

  describe "lookup/1" do
    test "returns :error for unknown command" do
      assert Registry.lookup("nonexistent") == :error
    end
  end

  describe "commands/0" do
    test "returns all registered commands" do
      cmds = Registry.commands()
      names = for {name, _, _} <- cmds, do: name
      assert "steam:status" in names
      assert "zgsm" in names
      assert "help" in names
      assert "h" in names
    end
  end

  describe "list_entries/0" do
    test "returns one entry per handler module" do
      entries = Registry.list_entries()
      modules = Enum.map(entries, & &1.module)
      assert length(entries) == length(Enum.uniq(modules))
    end
  end
end
