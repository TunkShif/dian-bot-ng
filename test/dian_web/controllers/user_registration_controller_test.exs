defmodule DianWeb.UserRegistrationControllerTest do
  use DianWeb.ConnCase

  import Dian.AccountsFixtures

  alias Dian.Accounts
  alias Dian.Repo

  describe "POST /api/users/register" do
    @tag :capture_log
    test "creates an unconfirmed account and sends a login link", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, ~p"/api/users/register", %{
          "user" => valid_user_attributes(email: email)
        })

      assert json_response(conn, 200) == %{"status" => "success", "data" => nil}

      user = Accounts.get_user_by_email(email)
      refute user.confirmed_at
      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "login"
    end

    test "returns changeset errors for invalid data", %{conn: conn} do
      conn =
        post(conn, ~p"/api/users/register", %{
          "user" => %{"email" => "with spaces"}
        })

      assert %{
               "status" => "fail",
               "data" => %{"email" => ["must have the @ sign and no spaces"]}
             } = json_response(conn, 422)
    end
  end
end
