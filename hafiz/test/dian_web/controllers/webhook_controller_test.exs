defmodule DianWeb.WebhookControllerTest do
  use DianWeb.ConnCase

  import Dian.Fixtures

  describe "event" do
    test "should fail with invalid event", %{conn: conn} do
      conn = post(conn, ~p"/webhooks/event", %{})
      assert json_response(conn, 401)
    end

    test "should succeed with valid event", %{conn: conn} do
      payload = fixture(:raw_event)

      signature =
        :crypto.mac(:hmac, :sha, "1234", payload) |> Base.encode16(case: :lower)

      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> put_req_header("x-signature", "sha1=" <> signature)
        |> post(~p"/webhooks/event", fixture(:raw_event))

      assert json_response(conn, 200)
    end
  end
end
