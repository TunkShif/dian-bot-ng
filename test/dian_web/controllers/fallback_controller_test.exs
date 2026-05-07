defmodule DianWeb.FallbackControllerTest do
  use DianWeb.ConnCase, async: true

  alias DianWeb.FallbackController

  test "returns a bad gateway response for email delivery failures", %{conn: conn} do
    conn = FallbackController.call(conn, {:error, {:email_delivery_failed, {422, %{}}}})

    assert json_response(conn, 502) == %{
             "status" => "fail",
             "data" => %{"message" => "failed to send email"}
           }
  end
end
