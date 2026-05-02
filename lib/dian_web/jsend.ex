defmodule DianWeb.JSend do
  import Plug.Conn
  import Phoenix.Controller

  def success_json(conn, data \\ nil, status \\ :ok) do
    conn
    |> put_status(status)
    |> json(success(data))
  end

  def fail_json(conn, data, status \\ :bad_request) do
    conn
    |> put_status(status)
    |> json(fail(data))
  end

  def error_json(conn, message, status \\ :internal_server_error, data \\ nil) do
    conn
    |> put_status(status)
    |> json(error(message, data))
  end

  def success(data \\ nil) do
    %{
      status: "success",
      data: data
    }
  end

  def fail(data) do
    %{
      status: "fail",
      data: data
    }
  end

  def error(message, data \\ nil) do
    %{
      status: "error",
      message: message,
      data: data
    }
  end
end
