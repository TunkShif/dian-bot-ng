defmodule DianWeb.BodyReader do
  @store_key :raw_req_body

  def get_raw_body(%Plug.Conn{} = conn) do
    case conn.private[@store_key] do
      nil -> nil
      chunks -> chunks |> Enum.reverse() |> Enum.join("")
    end
  end

  def read_body(%Plug.Conn{} = conn, opts \\ []) do
    case Plug.Conn.read_body(conn, opts) do
      {:ok, binary, conn} ->
        {:ok, binary, maybe_put_body_chunk(conn, binary)}

      {:more, binary, conn} ->
        {:more, binary, maybe_put_body_chunk(conn, binary)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp enabled?(conn) do
    case conn.path_info do
      ["webhooks" | _rest] -> true
      _ -> false
    end
  end

  defp maybe_put_body_chunk(conn, chunk) do
    if enabled?(conn) do
      put_body_chunk(conn, chunk)
    else
      conn
    end
  end

  defp put_body_chunk(%Plug.Conn{} = conn, chunk) when is_binary(chunk) do
    chunks = conn.private[@store_key] || []
    Plug.Conn.put_private(conn, @store_key, [chunk | chunks])
  end
end
