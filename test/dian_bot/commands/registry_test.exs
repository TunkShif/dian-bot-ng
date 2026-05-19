defmodule DianBot.Commands.RegistryTest do
  use ExUnit.Case, async: true

  alias DianBot.Commands.Registry

  describe "lookup/1" do
    test "returns :error for unknown command" do
      assert Registry.lookup("nonexistent") == :error
    end
  end

  describe "commands/0" do
    test "returns empty list initially" do
      assert Registry.commands() == []
    end
  end
end
