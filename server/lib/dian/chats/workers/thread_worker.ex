defmodule Dian.Chats.ThreadWorker do
  @moduledoc """
  Worker for creating new thread from incoming `Event`.
  """

  use Oban.Worker, max_attempts: 3, unique: [fields: [:args], keys: [:id]]

  alias Dian.Chats

  def perform(%Oban.Job{args: %{"id" => id}}) do
    key = "event:#{id}"

    # event struct passed into the job args will be serialized,
    # so here we're relying on cache to get the original event struct
    Cachex.transaction(Dian.Cache, [key], fn worker ->
      with {:ok, event} <- Cachex.get(worker, key),
           {:ok, _thread} <- Chats.create_thread(event),
           {:ok, true} <- Cachex.del(worker, key) do
        :ok
      end
    end)
  end
end
