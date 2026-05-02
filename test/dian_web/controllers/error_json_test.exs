defmodule DianWeb.ErrorJSONTest do
  use DianWeb.ConnCase, async: true

  test "renders 404" do
    assert DianWeb.ErrorJSON.render("404.json", %{}) == %{
             status: "fail",
             data: %{message: "Not Found"}
           }
  end

  test "renders 500" do
    assert DianWeb.ErrorJSON.render("500.json", %{}) ==
             %{status: "error", message: "Internal Server Error", data: nil}
  end
end
