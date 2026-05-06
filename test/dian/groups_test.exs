defmodule Dian.GroupsTest do
  use Dian.DataCase

  import Dian.AccountsFixtures
  import Dian.SteamFixtures

  alias Dian.Accounts.Scope
  alias Dian.Groups
  alias Dian.Settings.GlobalSetting
  alias Dian.Settings.GroupSetting

  describe "list_groups/1" do
    test "returns only groups where the current QQ user is a member" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)

      Mox.expect(DianBot.Client.Mock, :request, 3, fn
        "get_group_list", %{}, [] ->
          {:ok, [group_payload(100, "visible"), group_payload(200, "hidden")]}

        "get_group_member_info", %{group_id: 100, user_id: "12345", no_cache: false}, [] ->
          {:ok, member_payload(100, 12345, "member")}

        "get_group_member_info", %{group_id: 200, user_id: "12345", no_cache: false}, [] ->
          {:error, :not_found}
      end)

      assert {:ok, [%{group_id: 100, group_name: "visible", enabled: false, is_admin: false}]} =
               Groups.list_groups(scope)

      Mox.verify!()
    end
  end

  describe "update_group/3" do
    test "updates group settings when the current QQ user is a group admin" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "12345", no_cache: true},
        [
          no_cache: true
        ] ->
          {:ok, member_payload("100", 12345, "admin")}
      end)

      assert {:ok, %GroupSetting{group_id: "100", enabled: true}} =
               Groups.update_group(scope, "100", %{"enabled" => true})

      Mox.verify!()
    end

    test "rejects settings updates from non-admin group members" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "12345", no_cache: true},
        [
          no_cache: true
        ] ->
          {:ok, member_payload("100", 12345, "member")}
      end)

      assert {:error, :forbidden} = Groups.update_group(scope, "100", %{"enabled" => true})

      Mox.verify!()
    end
  end

  describe "get_group/2" do
    test "includes local steam binding summaries for members" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)
      steam_id = unique_steam_id()
      steam_player_fixture(qq_id: "20001", steam_id: steam_id, display_name: "PlayerOne")

      Mox.expect(DianBot.Client.Mock, :request, 3, fn
        "get_group_member_info", %{group_id: "100", user_id: "12345", no_cache: false}, [] ->
          {:ok, member_payload("100", 12345, "admin")}

        "get_group_info", %{group_id: "100"}, [] ->
          {:ok, group_payload("100", "visible")}

        "get_group_member_list", %{group_id: "100"}, [] ->
          {:ok, [member_payload("100", 12345, "admin"), member_payload("100", 20001, "member")]}
      end)

      assert {:ok, group} = Groups.get_group(scope, "100")

      assert [%{user_id: 12345, steam_player: nil}, %{user_id: 20001, steam_player: steam_player}] =
               group.members

      assert %{steam_id: ^steam_id, display_name: "PlayerOne"} = steam_player

      Mox.verify!()
    end
  end

  describe "authorize_group_admin/2" do
    test "returns :ok when user is a group admin" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "12345", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 12345, "admin")}
      end)

      assert :ok = Groups.authorize_group_admin(scope, "100")

      Mox.verify!()
    end

    test "returns :ok when user is a superadmin" do
      user = user_fixture(email: "12345@qq.com")
      Repo.update_all(GlobalSetting, set: [superadmin_user_id: user.id])
      scope = Scope.for_user(user)

      assert :ok = Groups.authorize_group_admin(scope, "100")
    end

    test "returns forbidden when user is a regular member" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "12345", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 12345, "member")}
      end)

      assert {:error, :forbidden} = Groups.authorize_group_admin(scope, "100")

      Mox.verify!()
    end

    test "returns forbidden when user is not a group member" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "12345", no_cache: true},
        [no_cache: true] ->
          {:error, :not_found}
      end)

      assert {:error, :forbidden} = Groups.authorize_group_admin(scope, "100")

      Mox.verify!()
    end

    test "propagates upstream member lookup errors" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "12345", no_cache: true},
        [no_cache: true] ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = Groups.authorize_group_admin(scope, "100")

      Mox.verify!()
    end

    test "performs uncached member lookup for mutating authorization" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "12345", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 12345, "admin")}
      end)

      assert :ok = Groups.authorize_group_admin(scope, "100")

      Mox.verify!()
    end
  end

  defp group_payload(group_id, name) do
    %{
      "group_id" => group_id,
      "group_name" => name,
      "group_remark" => "",
      "member_count" => 1
    }
  end

  defp member_payload(group_id, user_id, role) do
    %{
      "group_id" => group_id,
      "user_id" => user_id,
      "nickname" => "Dian User",
      "card" => "",
      "join_time" => 0,
      "last_sent_time" => 0,
      "is_robot" => false,
      "role" => role,
      "title" => ""
    }
  end

  defp group_user_fixture(qq_id) do
    user = user_fixture(email: "#{qq_id}@qq.com")
    Repo.update_all(GlobalSetting, set: [superadmin_user_id: -1])
    user
  end
end
