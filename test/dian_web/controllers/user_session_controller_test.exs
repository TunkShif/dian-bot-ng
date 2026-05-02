defmodule DianWeb.UserSessionControllerTest do
  use DianWeb.ConnCase

  import Dian.AccountsFixtures
  import Dian.SettingsFixtures

  alias Dian.Accounts
  alias Dian.Repo

  setup do
    stub_bot_group_member_info()

    %{unconfirmed_user: unconfirmed_user_fixture(), user: user_fixture()}
  end

  describe "POST /api/users/login - email and password" do
    test "logs the user in and redirects to the SPA dashboard", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        post(conn, ~p"/api/users/login", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/app/dashboard"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "flash.welcome"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        post(conn, ~p"/api/users/login", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_dian_web_user_remember_me"]
      assert redirected_to(conn) == ~p"/app/dashboard"
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      user = set_password(user)

      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/api/users/login", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "flash.welcome"
    end

    test "returns jsend fail with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/users/login", %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      assert json_response(conn, 401) == %{
               "status" => "fail",
               "data" => %{"message" => "failed to login"}
             }
    end
  end

  describe "POST /api/users/login - email only" do
    test "sends login link email when user exists", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/api/users/login", %{
          "user" => %{"email" => user.email}
        })

      assert json_response(conn, 200) == %{"status" => "success", "data" => nil}
      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "login"
    end

    test "returns success when the email does not exist", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/login", %{
          "user" => %{"email" => unique_user_email()}
        })

      assert json_response(conn, 200) == %{"status" => "success", "data" => nil}
    end
  end

  describe "GET /redirects/users/login/:token" do
    test "logs confirmed user in", %{conn: conn, user: user} do
      {token, _hashed_token} = generate_user_magic_link_token(user)

      conn = get(conn, ~p"/redirects/users/login/#{token}")

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/app/dashboard"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "flash.welcome"
    end

    test "confirms and logs unconfirmed user in", %{conn: conn, unconfirmed_user: user} do
      {token, _hashed_token} = generate_user_magic_link_token(user)
      refute user.confirmed_at

      conn = get(conn, ~p"/redirects/users/login/#{token}")

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/app/dashboard"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "flash.set_password_prompt"
      assert Accounts.get_user!(user.id).confirmed_at
    end

    test "redirects to SPA login for invalid token", %{conn: conn} do
      conn = get(conn, ~p"/redirects/users/login/invalid-token")

      assert redirected_to(conn) == ~p"/app/login"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "flash.invalid_token"
    end
  end

  describe "DELETE /redirects/users/logout" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/redirects/users/logout")

      assert redirected_to(conn) == ~p"/app/login"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "flash.logout"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/redirects/users/logout")

      assert redirected_to(conn) == ~p"/app/login"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "flash.logout"
    end
  end
end
