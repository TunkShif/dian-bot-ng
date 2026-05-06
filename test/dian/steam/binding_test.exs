defmodule Dian.Steam.BindingTest do
  use Dian.DataCase

  import Dian.AccountsFixtures
  import Dian.SteamFixtures

  alias Dian.Accounts.Scope
  alias Dian.Settings.GlobalSetting
  alias Dian.Steam
  alias Dian.Steam.SteamPlayer

  defp group_user_fixture(qq_id) do
    user = user_fixture(email: "#{qq_id}@qq.com")
    Repo.update_all(GlobalSetting, set: [superadmin_user_id: -1])
    user
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

  describe "upsert_binding/2" do
    test "creates a new binding" do
      assert {:ok, %SteamPlayer{}} = Steam.upsert_binding("12345", unique_steam_id())
    end

    test "replaces conflicting binding with same qq_id" do
      steam_id_1 = unique_steam_id()
      steam_id_2 = unique_steam_id()
      {:ok, _old} = Steam.upsert_binding("12345", steam_id_1)

      assert {:ok, %SteamPlayer{steam_id: ^steam_id_2, qq_id: "12345"}} =
               Steam.upsert_binding("12345", steam_id_2)

      refute Steam.get_steam_player_by_steam_id(steam_id_1)
    end

    test "replaces conflicting binding with same steam_id" do
      steam_id = unique_steam_id()
      {:ok, _old} = Steam.upsert_binding("11111", steam_id)

      assert {:ok, %SteamPlayer{steam_id: ^steam_id, qq_id: "22222"}} =
               Steam.upsert_binding("22222", steam_id)

      refute Steam.get_steam_player_by_qq_id("11111")
    end

    test "replaces both conflicting bindings atomically" do
      steam_id = unique_steam_id()
      {:ok, _old_by_steam} = Steam.upsert_binding("11111", steam_id)
      {:ok, _old_by_qq} = Steam.upsert_binding("22222", unique_steam_id())

      assert {:ok, %SteamPlayer{steam_id: ^steam_id, qq_id: "22222"}} =
               Steam.upsert_binding("22222", steam_id)

      refute Steam.get_steam_player_by_qq_id("11111")
    end

    test "returns changeset error for invalid steam_id" do
      assert {:error, %Ecto.Changeset{}} = Steam.upsert_binding("12345", "bad")
    end

    test "returns changeset error for invalid qq_id" do
      assert {:error, %Ecto.Changeset{}} = Steam.upsert_binding("abc", unique_steam_id())
    end
  end

  describe "bind_self/2" do
    test "binds the authenticated user's qq_id to a steam_id" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)
      steam_id = unique_steam_id()

      assert {:ok, %SteamPlayer{qq_id: "12345", steam_id: ^steam_id}} =
               Steam.bind_self(scope, steam_id)
    end

    test "replaces the user's existing binding" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)
      old_steam_id = unique_steam_id()
      new_steam_id = unique_steam_id()

      {:ok, _old} = Steam.bind_self(scope, old_steam_id)

      assert {:ok, %SteamPlayer{qq_id: "12345", steam_id: ^new_steam_id}} =
               Steam.bind_self(scope, new_steam_id)

      refute Steam.get_steam_player_by_steam_id(old_steam_id)
    end

    test "persists the looked-up display_name when provided" do
      user = group_user_fixture("12345")
      scope = Scope.for_user(user)
      steam_id = unique_steam_id()

      assert {:ok, %SteamPlayer{qq_id: "12345", steam_id: ^steam_id, display_name: "PlayerOne"}} =
               Steam.bind_self(scope, steam_id, "PlayerOne")
    end
  end

  describe "bind_member/4" do
    test "succeeds when actor is group admin and target is group member" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)
      target_qq_id = "20001"
      steam_id = unique_steam_id()

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 10001, "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "20001", no_cache: false}, [] ->
          {:ok, member_payload("100", 20001, "member")}
      end)

      assert {:ok, %SteamPlayer{qq_id: ^target_qq_id, steam_id: ^steam_id}} =
               Steam.bind_member(scope, "100", target_qq_id, steam_id)

      Mox.verify!()
    end

    test "rejects when actor is not a group admin" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 10001, "member")}
      end)

      assert {:error, :forbidden} = Steam.bind_member(scope, "100", "20001", unique_steam_id())

      Mox.verify!()
    end

    test "rejects when actor is not a member of the group at all" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:error, :not_found}
      end)

      assert {:error, :forbidden} = Steam.bind_member(scope, "100", "20001", unique_steam_id())

      Mox.verify!()
    end

    test "rejects when target qq_id is not a member of the group" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 10001, "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "99999", no_cache: false}, [] ->
          {:error, :not_found}
      end)

      assert {:error, :not_found} = Steam.bind_member(scope, "100", "99999", unique_steam_id())

      Mox.verify!()
    end

    test "propagates upstream target member lookup errors" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 10001, "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "20001", no_cache: false}, [] ->
          {:error, :timeout}
      end)

      assert {:error, :timeout} = Steam.bind_member(scope, "100", "20001", unique_steam_id())

      Mox.verify!()
    end

    test "uses no_cache: true for the actor admin check" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 10001, "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "20001", no_cache: false}, [] ->
          {:ok, member_payload("100", 20001, "member")}
      end)

      assert {:ok, _} = Steam.bind_member(scope, "100", "20001", unique_steam_id())

      Mox.verify!()
    end

    test "upsert overrides prior conflicting steam_id binding" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)
      target_qq_id = "20001"
      conflicting_steam_id = unique_steam_id()

      {:ok, _other} = Steam.upsert_binding("30001", conflicting_steam_id)

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 10001, "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "20001", no_cache: false}, [] ->
          {:ok, member_payload("100", 20001, "member")}
      end)

      assert {:ok, %SteamPlayer{qq_id: ^target_qq_id, steam_id: ^conflicting_steam_id}} =
               Steam.bind_member(scope, "100", target_qq_id, conflicting_steam_id)

      refute Steam.get_steam_player_by_qq_id("30001")

      Mox.verify!()
    end

    test "upsert overrides prior conflicting qq_id binding" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)
      target_qq_id = "20001"
      old_steam_id = unique_steam_id()
      new_steam_id = unique_steam_id()

      {:ok, _old} = Steam.upsert_binding(target_qq_id, old_steam_id)

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 10001, "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "20001", no_cache: false}, [] ->
          {:ok, member_payload("100", 20001, "member")}
      end)

      assert {:ok, %SteamPlayer{qq_id: ^target_qq_id, steam_id: ^new_steam_id}} =
               Steam.bind_member(scope, "100", target_qq_id, new_steam_id)

      refute Steam.get_steam_player_by_steam_id(old_steam_id)

      Mox.verify!()
    end

    test "persists the looked-up display_name when provided" do
      actor = group_user_fixture("10001")
      scope = Scope.for_user(actor)
      target_qq_id = "20001"
      steam_id = unique_steam_id()

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: "10001", no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", 10001, "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "20001", no_cache: false}, [] ->
          {:ok, member_payload("100", 20001, "member")}
      end)

      assert {:ok,
              %SteamPlayer{
                qq_id: ^target_qq_id,
                steam_id: ^steam_id,
                display_name: "PlayerOne"
              }} =
               Steam.bind_member(scope, "100", target_qq_id, steam_id, "PlayerOne")

      Mox.verify!()
    end
  end

  describe "get_bound_player_summary_by_qq_id/1" do
    test "returns summary when binding exists and Steam profile resolves" do
      steam_id = unique_steam_id()
      steam_player_fixture(steam_id: steam_id, qq_id: "12345")

      summary = %Dian.Steam.PlayerSummary{
        steam_id: steam_id,
        name: "PlayerOne",
        state: :online
      }

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [^steam_id] ->
        {:ok, [summary]}
      end)

      assert {:ok, ^summary} = Steam.get_bound_player_summary_by_qq_id("12345")

      Mox.verify!()
    end

    test "returns not_found when Steam profile no longer exists" do
      steam_id = unique_steam_id()
      steam_player_fixture(steam_id: steam_id, qq_id: "12345")

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [^steam_id] ->
        {:ok, []}
      end)

      assert {:error, :not_found} = Steam.get_bound_player_summary_by_qq_id("12345")

      Mox.verify!()
    end

    test "returns steam_api_error when Steam client fails" do
      steam_id = unique_steam_id()
      steam_player_fixture(steam_id: steam_id, qq_id: "12345")

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [^steam_id] ->
        {:error, :request_error}
      end)

      assert {:error, :steam_api_error} = Steam.get_bound_player_summary_by_qq_id("12345")

      Mox.verify!()
    end

    test "returns ok with nil player when no binding exists for qq_id" do
      assert {:ok, nil} = Steam.get_bound_player_summary_by_qq_id("99999")
    end
  end
end
