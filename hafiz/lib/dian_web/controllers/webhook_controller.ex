defmodule DianWeb.WebhookController do
  use DianWeb, :controller

  alias DianBot.BotError
  alias DianWeb.BodyReader
  alias Dian.Chats.ThreadWorker

  def event(conn, params) do
    payload = BodyReader.get_raw_body(conn)
    signature = get_req_header(conn, "x-signature") |> List.first()

    with {:ok, event} <- DianBot.parse_event(params, payload: payload, signature: signature),
         {:ok, _} <- Cachex.put(Dian.Cache, "event:#{event.id}", event, ttl: :timer.minutes(2)),
         {:ok, _job} <- ThreadWorker.new(%{id: event.id}) |> Oban.insert() do
      conn |> json(%{data: nil})
    else
      {:error, %BotError{message: "unauthorized event source"}} ->
        conn |> put_status(:unauthorized) |> json(%{data: nil})

      _ ->
        conn |> put_status(:bad_request) |> json(%{data: nil})
    end
  end
end
