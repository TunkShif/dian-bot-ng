defmodule DianWeb.PageController do
  use DianWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: ~p"/app/dashboard")
  end

  def home(conn, _params) do
    render(conn, :home)
  end
end
