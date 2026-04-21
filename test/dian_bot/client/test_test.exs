defmodule DianBot.Client.TestTest do
  use ExUnit.Case, async: false

  alias DianBot.Client
  alias DianBot.Client.Test, as: TestClient

  setup do
    start_supervised!(TestClient)
    :ok
  end

  test "unstubbed actions return explicit error" do
    assert Client.request("missing_action", %{"page" => 1}, timeout: 10) ==
             {:error, {:not_stubbed, "missing_action"}}
  end

  test "stubbed action returns configured response" do
    TestClient.stub("get_group_list", fn params, opts ->
      assert params == %{"page" => 1}
      assert opts == [timeout: 10]
      {:ok, [%{"group_id" => 123, "group_name" => "test"}]}
    end)

    assert Client.get_group_list(%{"page" => 1}, timeout: 10) ==
             {:ok, [%{"group_id" => 123, "group_name" => "test"}]}
  end

  test "stubs are replaced for the same action" do
    TestClient.stub("get_group_list", fn _params, _opts -> {:ok, [:first]} end)
    TestClient.stub("get_group_list", fn _params, _opts -> {:ok, [:second]} end)

    assert Client.get_group_list(%{}) == {:ok, [:second]}
  end
end
