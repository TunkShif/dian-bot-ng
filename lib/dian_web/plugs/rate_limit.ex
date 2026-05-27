defmodule DianWeb.Plugs.RateLimit do
  @moduledoc """
  Simple IP-based rate limiting plug using ETS.

  Limits requests by IP address within a configurable time window.
  """

  import Plug.Conn

  @table :rate_limit_table
  @default_window_ms :timer.minutes(15)
  @default_max_requests 5

  def init(opts) do
    %{
      window_ms: Keyword.get(opts, :window_ms, @default_window_ms),
      max_requests: Keyword.get(opts, :max_requests, @default_max_requests)
    }
  end

  def call(conn, %{window_ms: window_ms, max_requests: max_requests}) do
    ip = get_client_ip(conn)
    now = System.system_time(:millisecond)

    case check_rate(ip, now, window_ms, max_requests) do
      :ok ->
        conn

      {:error, retry_after_ms} ->
        retry_after_seconds = div(retry_after_ms, 1000) + 1

        conn
        |> put_resp_header("retry-after", Integer.to_string(retry_after_seconds))
        |> put_resp_content_type("application/json")
        |> send_resp(
          429,
          Jason.encode!(%{
            status: "fail",
            data: %{message: "too many requests, retry in #{retry_after_seconds} seconds"}
          })
        )
        |> halt()
    end
  end

  defp check_rate(key, now, window_ms, max_requests) do
    ensure_table()

    # Atomically increment the counter (or create the entry with count=1 if absent).
    # update_counter with a default value is fully atomic — no TOCTOU gap.
    new_count = :ets.update_counter(@table, key, {2, 1}, {key, 0, now})

    [{^key, _count, window_start}] = :ets.lookup(@table, key)

    if now - window_start >= window_ms do
      # Window has expired — reset the entry for a fresh window.
      :ets.insert(@table, {key, 1, now})
      :ok
    else
      if new_count > max_requests do
        {:error, window_ms - (now - window_start)}
      else
        :ok
      end
    end
  end

  defp get_client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [forwarded | _] ->
        forwarded
        |> String.split(",", parts: 2)
        |> List.first()
        |> String.trim()

      [] ->
        conn.remote_ip
        |> Tuple.to_list()
        |> Enum.join(".")
    end
  end

  defp ensure_table do
    case :ets.info(@table) do
      :undefined ->
        :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])

      _ ->
        :ok
    end
  end
end
