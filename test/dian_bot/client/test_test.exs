defmodule DianBot.Client.TestTest do
  use ExUnit.Case, async: false

  alias DianBot.Client
  alias DianBot.Client.Test, as: TestClient
  alias DianBot.Group
  alias DianBot.GroupMember

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
      assert params == %{}
      assert opts == [timeout: 10]

      {:ok,
       [
         %{
           "group_all_shut" => 0,
           "group_remark" => "",
           "group_id" => 123,
           "group_name" => "test",
           "member_count" => 31,
           "max_member_count" => 200
         }
       ]}
    end)

    assert Client.get_group_list(timeout: 10) ==
             {:ok,
              [
                %Group{
                  group_id: 123,
                  group_name: "test",
                  group_remark: "",
                  member_count: 31
                }
              ]}
  end

  test "get_group_info returns group struct subset" do
    TestClient.stub("get_group_info", fn params, opts ->
      assert params == %{group_id: "627254018"}
      assert opts == [timeout: 10]

      {:ok,
       %{
         "group_all_shut" => 0,
         "group_remark" => "",
         "group_id" => 627_254_018,
         "group_name" => "test group",
         "member_count" => 31,
         "max_member_count" => 200
       }}
    end)

    assert Client.get_group_info("627254018", timeout: 10) ==
             {:ok,
              %Group{
                group_id: 627_254_018,
                group_name: "test group",
                group_remark: "",
                member_count: 31
              }}
  end

  test "get_group_member_info returns group member struct subset" do
    TestClient.stub("get_group_member_info", fn params, opts ->
      assert params == %{
               group_id: "627254018",
               user_id: "1395084414",
               no_cache: false
             }

      assert opts == [timeout: 10]

      {:ok, group_member_payload()}
    end)

    assert Client.get_group_member_info("627254018", "1395084414", timeout: 10) ==
             {:ok, group_member_struct()}
  end

  test "get_group_member_list returns group member struct subsets" do
    TestClient.stub("get_group_member_list", fn params, opts ->
      assert params == %{group_id: "627254018", no_cache: false}
      assert opts == []

      {:ok, [group_member_payload()]}
    end)

    assert Client.get_group_member_list("627254018") ==
             {:ok, [group_member_struct()]}
  end

  test "stubs are replaced for the same action" do
    TestClient.stub("get_group_list", fn _params, _opts ->
      {:ok,
       [
         %{
           "group_remark" => "",
           "group_id" => 1,
           "group_name" => "first",
           "member_count" => 31
         }
       ]}
    end)

    TestClient.stub("get_group_list", fn _params, _opts ->
      {:ok,
       [
         %{
           "group_remark" => "",
           "group_id" => 2,
           "group_name" => "second",
           "member_count" => 31
         }
       ]}
    end)

    assert Client.get_group_list() ==
             {:ok,
              [
                %Group{
                  group_id: 2,
                  group_name: "second",
                  group_remark: "",
                  member_count: 31
                }
              ]}
  end

  defp group_member_payload do
    %{
      "group_id" => 627_254_018,
      "user_id" => 1_395_084_414,
      "nickname" => "test member",
      "card" => "member card",
      "sex" => "male",
      "age" => 0,
      "area" => "",
      "level" => "100",
      "qq_level" => 71,
      "join_time" => 1_747_738_298,
      "last_sent_time" => 1_777_704_338,
      "title_expire_time" => 0,
      "unfriendly" => false,
      "card_changeable" => true,
      "is_robot" => false,
      "shut_up_timestamp" => 0,
      "role" => "member",
      "title" => ""
    }
  end

  defp group_member_struct do
    %GroupMember{
      group_id: 627_254_018,
      user_id: 1_395_084_414,
      nickname: "test member",
      display_name: "member card",
      join_time: 1_747_738_298,
      last_sent_time: 1_777_704_338,
      is_robot: false,
      role: "member",
      title: ""
    }
  end
end
