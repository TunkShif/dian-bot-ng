defmodule DianWeb.SteamPlayerControllerTest do
  use DianWeb.ConnCase

  import Dian.SteamFixtures

  alias Dian.Accounts
  alias Dian.Repo
  alias Dian.Settings.GlobalSetting

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

  describe "GET /api/steam/players/:steam_id" do
    setup :register_and_log_in_user

    test "returns player summary for a valid steam_id", %{conn: conn} do
      summary = %Dian.Steam.PlayerSummary{
        steam_id: "76561198000000000",
        name: "PlayerOne",
        state: :online
      }

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn ["76561198000000000"] ->
        {:ok, [summary]}
      end)

      conn = get(conn, "/api/steam/players/76561198000000000")

      assert %{
               "status" => "success",
               "data" => %{
                 "player" => %{
                   "steam_id" => "76561198000000000",
                   "name" => "PlayerOne",
                   "state" => "online"
                 }
               }
             } = json_response(conn, 200)

      Mox.verify!()
    end

    test "returns 404 when Steam profile not found", %{conn: conn} do
      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn ["76561198000000000"] ->
        {:ok, []}
      end)

      conn = get(conn, "/api/steam/players/76561198000000000")

      assert %{"status" => "fail"} = json_response(conn, 404)

      Mox.verify!()
    end

    test "returns 502 when Steam lookup has transport failure", %{conn: conn} do
      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn ["76561198000000000"] ->
        {:error, :request_error}
      end)

      conn = get(conn, "/api/steam/players/76561198000000000")

      assert %{"status" => "fail"} = json_response(conn, 502)

      Mox.verify!()
    end
  end

  describe "GET /api/steam/players/by-qq/:qq_id" do
    setup :register_and_log_in_user

    test "returns player summary when binding exists and Steam resolves", %{conn: conn} do
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

      conn = get(conn, "/api/steam/players/by-qq/12345")

      assert %{
               "status" => "success",
               "data" => %{"player" => %{"steam_id" => ^steam_id}}
             } = json_response(conn, 200)

      Mox.verify!()
    end

    test "returns 404 for stale binding whose Steam ID no longer resolves", %{conn: conn} do
      steam_id = unique_steam_id()
      steam_player_fixture(steam_id: steam_id, qq_id: "12345")

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [^steam_id] ->
        {:ok, []}
      end)

      conn = get(conn, "/api/steam/players/by-qq/12345")

      assert %{"status" => "fail"} = json_response(conn, 404)

      Mox.verify!()
    end

    test "does not return 502 for stale binding", %{conn: conn} do
      steam_id = unique_steam_id()
      steam_player_fixture(steam_id: steam_id, qq_id: "12345")

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [^steam_id] ->
        {:ok, []}
      end)

      conn = get(conn, "/api/steam/players/by-qq/12345")

      assert conn.status != 502

      Mox.verify!()
    end

    test "returns 502 when Steam API has transport failure", %{conn: conn} do
      steam_id = unique_steam_id()
      steam_player_fixture(steam_id: steam_id, qq_id: "12345")

      Mox.expect(Dian.Steam.Client.Mock, :get_player_summaries, fn [^steam_id] ->
        {:error, :request_error}
      end)

      conn = get(conn, "/api/steam/players/by-qq/12345")

      assert %{"status" => "fail"} = json_response(conn, 502)

      Mox.verify!()
    end

    test "returns 200 with null player when no binding exists for qq_id", %{conn: conn} do
      conn = get(conn, "/api/steam/players/by-qq/99999")

      assert %{"status" => "success", "data" => %{"player" => nil}} = json_response(conn, 200)
    end
  end

  describe "PUT /api/steam/players/self" do
    setup :register_and_log_in_user

    test "binds the authenticated user's qq_id to a steam_id", %{conn: conn, user: user} do
      qq_id = Accounts.extract_qq_id_from(user.email)
      steam_id = unique_steam_id()

      conn = put(conn, "/api/steam/players/self", %{"steam_id" => steam_id})

      assert %{
               "status" => "success",
               "data" => %{
                 "binding" => %{"qq_id" => ^qq_id, "steam_id" => ^steam_id}
               }
             } = json_response(conn, 200)
    end

    test "returns validation error for invalid steam_id", %{conn: conn} do
      conn = put(conn, "/api/steam/players/self", %{"steam_id" => "bad"})

      assert %{"status" => "fail"} = json_response(conn, 422)
    end
  end

  describe "PUT /api/steam/players/group-members/:group_id/:qq_id" do
    setup :register_and_log_in_user

    test "returns 403 for non-admin", %{conn: conn, user: user} do
      qq_id = Accounts.extract_qq_id_from(user.email)
      Repo.update_all(GlobalSetting, set: [superadmin_user_id: -1])

      Mox.expect(DianBot.Client.Mock, :request, fn
        "get_group_member_info",
        %{group_id: "100", user_id: ^qq_id, no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", String.to_integer(qq_id), "member")}
      end)

      conn =
        put(conn, "/api/steam/players/group-members/100/20001", %{
          "steam_id" => unique_steam_id()
        })

      assert %{"status" => "fail", "data" => %{"message" => "forbidden"}} =
               json_response(conn, 403)

      Mox.verify!()
    end

    test "returns 404 when target is not in the group", %{conn: conn, user: user} do
      qq_id = Accounts.extract_qq_id_from(user.email)
      Repo.update_all(GlobalSetting, set: [superadmin_user_id: -1])

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: ^qq_id, no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", String.to_integer(qq_id), "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "99999", no_cache: false}, [] ->
          {:error, :not_found}
      end)

      conn =
        put(conn, "/api/steam/players/group-members/100/99999", %{
          "steam_id" => unique_steam_id()
        })

      assert %{"status" => "fail"} = json_response(conn, 404)

      Mox.verify!()
    end

    test "returns 200 for valid admin bind", %{conn: conn, user: user} do
      qq_id = Accounts.extract_qq_id_from(user.email)
      Repo.update_all(GlobalSetting, set: [superadmin_user_id: -1])
      steam_id = unique_steam_id()

      Mox.expect(DianBot.Client.Mock, :request, 2, fn
        "get_group_member_info",
        %{group_id: "100", user_id: ^qq_id, no_cache: true},
        [no_cache: true] ->
          {:ok, member_payload("100", String.to_integer(qq_id), "admin")}

        "get_group_member_info", %{group_id: "100", user_id: "20001", no_cache: false}, [] ->
          {:ok, member_payload("100", 20001, "member")}
      end)

      conn =
        put(conn, "/api/steam/players/group-members/100/20001", %{
          "steam_id" => steam_id
        })

      assert %{
               "status" => "success",
               "data" => %{
                 "binding" => %{"qq_id" => "20001", "steam_id" => ^steam_id}
               }
             } = json_response(conn, 200)

      Mox.verify!()
    end
  end

  describe "PUT /api/steam/players/self without authentication" do
    test "redirects to login", %{conn: conn} do
      conn = put(conn, "/api/steam/players/self", %{"steam_id" => unique_steam_id()})
      assert redirected_to(conn) == ~p"/app/login"
    end
  end

  describe "PUT /api/steam/players/group-members/:group_id/:qq_id without authentication" do
    test "redirects to login", %{conn: conn} do
      conn =
        put(conn, "/api/steam/players/group-members/100/20001", %{
          "steam_id" => unique_steam_id()
        })

      assert redirected_to(conn) == ~p"/app/login"
    end
  end
end
