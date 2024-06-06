defmodule DianWeb.PageController do
  use DianWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
