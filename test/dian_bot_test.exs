defmodule DianBotTest do
  use ExUnit.Case, async: false

  alias DianBot.Message

  describe "send_msg/4" do
    test "sends group messages built from message segments" do
      Mox.expect(DianBot.Client.Mock, :request, fn
        "send_msg",
        %{
          message_type: "group",
          group_id: 100,
          message: [
            %{"type" => "text", "data" => %{"text" => "hello"}},
            %{"type" => "at", "data" => %{"qq" => "12345"}}
          ]
        },
        [] ->
          {:ok, %{"message_id" => 987_654}}
      end)

      assert DianBot.send_msg(:group, 100, [Message.text("hello"), Message.at("12345")]) ==
               {:ok, 987_654}

      Mox.verify!()
    end
  end

  describe "find_group_member_in_groups/2" do
    test "returns the first successful group member lookup" do
      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info", %{group_id: 100, user_id: "12345", no_cache: false}, [] ->
          {:error, :not_found}

        "get_group_member_info", %{group_id: 200, user_id: "12345", no_cache: false}, [] ->
          {:ok,
           %{
             "group_id" => 200,
             "user_id" => 12345,
             "nickname" => "Dian User",
             "card" => "",
             "join_time" => 0,
             "last_sent_time" => 0,
             "is_robot" => false,
             "role" => "member",
             "title" => ""
           }}
      end)

      assert %{group_id: 200, user_id: 12345, nickname: "Dian User"} =
               DianBot.find_group_member_in_groups([100, 200], "12345")

      Mox.verify!()
    end

    test "returns nil when no group lookup succeeds" do
      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info", %{group_id: 100, user_id: "12345", no_cache: false}, [] ->
          {:error, :not_found}

        "get_group_member_info", %{group_id: 200, user_id: "12345", no_cache: false}, [] ->
          {:error, :not_found}
      end)

      assert DianBot.find_group_member_in_groups([100, 200], "12345") == nil

      Mox.verify!()
    end
  end

  describe "find_group_member_in_any_group/1" do
    test "loads bot groups and returns the first successful group member lookup" do
      Mox.expect(DianBot.Client.Mock, :request, 3, fn
        "get_group_list", %{}, [] ->
          {:ok,
           [
             %{
               "group_id" => 100,
               "group_name" => "first",
               "group_remark" => "",
               "member_count" => 1
             },
             %{
               "group_id" => 200,
               "group_name" => "second",
               "group_remark" => "",
               "member_count" => 1
             }
           ]}

        "get_group_member_info", %{group_id: 100, user_id: "12345", no_cache: false}, [] ->
          {:error, :not_found}

        "get_group_member_info", %{group_id: 200, user_id: "12345", no_cache: false}, [] ->
          {:ok,
           %{
             "group_id" => 200,
             "user_id" => 12345,
             "nickname" => "Dian User",
             "card" => "",
             "join_time" => 0,
             "last_sent_time" => 0,
             "is_robot" => false,
             "role" => "member",
             "title" => ""
           }}
      end)

      assert %{group_id: 200, user_id: 12345, nickname: "Dian User"} =
               DianBot.find_group_member_in_any_group("12345")

      Mox.verify!()
    end

    test "returns nil when group list lookup fails" do
      Mox.expect(DianBot.Client.Mock, :request, fn "get_group_list", %{}, [] ->
        {:error, :unavailable}
      end)

      assert DianBot.find_group_member_in_any_group("12345") == nil

      Mox.verify!()
    end
  end
end
