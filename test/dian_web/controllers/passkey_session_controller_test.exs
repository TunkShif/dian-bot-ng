defmodule DianWeb.PasskeySessionControllerTest do
  use DianWeb.ConnCase

  describe "POST /api/passkeys/login/begin" do
    test "returns WebAuthn request options and stores the challenge", %{conn: conn} do
      conn = post(conn, ~p"/api/passkeys/login/begin")

      assert %{
               "status" => "success",
               "data" => %{
                 "options" => %{
                   "challenge" => challenge,
                   "rpId" => _rp_id,
                   "userVerification" => "preferred"
                 }
               }
             } = json_response(conn, 200)

      assert is_binary(challenge)
      assert %Wax.Challenge{} = get_session(conn, :webauthn_authentication_challenge)
    end
  end

  describe "POST /api/passkeys/login/complete" do
    test "returns a failure when no authentication challenge exists", %{conn: conn} do
      conn = post(conn, ~p"/api/passkeys/login/complete", %{})

      assert json_response(conn, 400) == %{
               "status" => "fail",
               "data" => %{"message" => "passkey authentication challenge not found"}
             }
    end
  end

  describe "GET /api/passkeys" do
    setup :register_and_log_in_user

    test "returns an empty passkey list", %{conn: conn} do
      conn = get(conn, ~p"/api/passkeys")

      assert json_response(conn, 200) == %{
               "status" => "success",
               "data" => %{"passkeys" => []}
             }
    end
  end
end
