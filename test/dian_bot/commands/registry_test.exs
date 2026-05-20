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
    end
  end
end
