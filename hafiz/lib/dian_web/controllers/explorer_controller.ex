defmodule DianWeb.ExplorerController do
  use DianWeb, :controller

  plug :accepts, ["html"]

  def index(conn, _params) do
    render(conn, :index, layout: false)
  end
end
