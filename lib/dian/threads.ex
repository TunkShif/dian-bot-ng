defmodule Dian.Threads do
  @moduledoc """
  Context for managing saved message threads.

  Threads are per-group collections of messages created by bot commands
  (`/thread:save`, `/thread:append`). Each thread stores one or more messages
  with their original OneBot segments preserved as JSON.
  """

  import Ecto.Query, warn: false
  alias Dian.Repo
  alias Dian.Threads.{Message, Thread}

  @doc """
  Creates a thread with one or more messages in a single transaction.

  `attrs` must include `group_id` and `creator_id`.
  `messages_data` is a list of maps with `raw_message_id`, `sender_id`,
  `segments` (list of maps), `types` (list of strings), and optional
  `text_content`.

  Returns `{:ok, %{thread: %Thread{}, messages: [%Message{}]}}` or
  `{:error, %Ecto.Changeset{}}`.
  """
  def create_thread_with_messages(attrs, messages_data) when is_list(messages_data) do
    Repo.transact(fn repo ->
      thread = %Thread{} |> Thread.changeset(attrs) |> repo.insert!()

      messages =
        Enum.map(messages_data, fn msg_attrs ->
          %Message{}
          |> Message.changeset(Map.put(msg_attrs, :thread_id, thread.id))
          |> repo.insert!()
        end)

      {:ok, %{thread: thread, messages: messages}}
    end)
  end
end
