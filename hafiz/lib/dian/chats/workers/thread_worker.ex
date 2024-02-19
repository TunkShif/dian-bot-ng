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
    with {:ok, event} <- Cachex.get(Dian.Cache, key),
         {:ok, _thread} <- Chats.create_thread(event) do
      # TODO: reviewing this later
      DianBot.set_honorable_message(event.message.mid)
      DianBot.send_group_message(event.group.gid, "[CQ:at,qq=#{event.owner.qid}]sdxd")
      :ok
    end
  end
end
