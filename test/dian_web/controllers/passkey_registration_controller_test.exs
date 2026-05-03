defmodule DianWeb.PasskeyRegistrationControllerTest do
  use DianWeb.ConnCase

  describe "POST /api/passkeys/registration/begin" do
    setup :register_and_log_in_user

    test "returns WebAuthn creation options and stores the challenge", %{conn: conn} do
      conn = post(conn, ~p"/api/passkeys/registration/begin")

      assert %{
               "status" => "success",
               "data" => %{
                 "options" => %{
                   "challenge" => challenge,
                   "rp" => %{"id" => _rp_id, "name" => _rp_name},
                   "user" => %{"id" => _user_id, "name" => _user_name}
                 }
               }
             } = json_response(conn, 200)

      assert is_binary(challenge)
      assert %Wax.Challenge{} = get_session(conn, :webauthn_registration_challenge)
    end
  end

  describe "POST /api/passkeys/registration/complete" do
    setup :register_and_log_in_user

    test "returns a failure when no registration challenge exists", %{conn: conn} do
      conn = post(conn, ~p"/api/passkeys/registration/complete", %{})

      assert json_response(conn, 400) == %{
               "status" => "fail",
               "data" => %{"message" => "passkey registration challenge not found"}
             }
    end
  end
end
