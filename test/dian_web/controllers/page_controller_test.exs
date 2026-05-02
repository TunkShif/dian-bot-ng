defmodule DianWeb.PageControllerTest do
  use DianWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/app/dashboard"
  end
end
