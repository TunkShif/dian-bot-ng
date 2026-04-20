defmodule DianWeb.PageController do
  use DianWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
