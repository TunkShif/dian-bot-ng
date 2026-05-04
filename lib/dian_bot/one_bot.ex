defmodule DianBot.OneBot do
  @moduledoc false

  @spec build_request(String.t(), String.t(), map()) :: map()
  def build_request(request_id, action, params) do
    %{
      "echo" => request_id,
      "action" => action,
      "params" => params
    }
  end

  @spec classify_payload(map()) :: :event | :response | :ignored
  def classify_payload(%{"post_type" => _event_type}), do: :event
  def classify_payload(%{"echo" => _request_id}), do: :response
  def classify_payload(_), do: :ignored

  @spec response_result(map()) :: {:ok, term()} | {:error, map()}
  def response_result(%{"status" => "ok", "retcode" => 0} = payload) do
    {:ok, Map.get(payload, "data")}
  end

  def response_result(payload) do
    {:error, Map.drop(payload, ["data", "echo"])}
  end
end
