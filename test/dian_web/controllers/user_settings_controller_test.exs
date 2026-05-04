defmodule DianWeb.UserSettingsControllerTest do
  use DianWeb.ConnCase

  alias Dian.Accounts
  alias Dian.Accounts.UserToken
  alias Dian.Repo

  describe "PATCH /api/users/settings" do
    setup :register_and_log_in_user

    test "updates the authenticated user's password and keeps the session active", %{
      conn: conn,
      user: user
    } do
      conn =
        patch(conn, ~p"/api/users/settings", %{
          "user" => %{"password" => "new valid password"}
        })

      assert json_response(conn, 200) == %{"status" => "success", "data" => nil}
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
      assert Repo.get_by(UserToken, user_id: user.id, context: "session")
    end

    test "returns changeset errors for invalid password params", %{conn: conn} do
      conn =
        patch(conn, ~p"/api/users/settings", %{
          "user" => %{
            "password" => "short",
            "password_confirmation" => "different"
          }
        })

      assert %{
               "status" => "fail",
               "data" => %{
                 "password" => ["should be at least 12 character(s)"],
                 "password_confirmation" => ["does not match password"]
               }
             } = json_response(conn, 422)
    end
  end

  describe "PATCH /api/users/settings without authentication" do
    test "redirects to the login page", %{conn: conn} do
      conn =
        patch(conn, ~p"/api/users/settings", %{
          "user" => %{"password" => "new valid password"}
        })

      assert redirected_to(conn) == ~p"/app/login"
    end
  end
end
