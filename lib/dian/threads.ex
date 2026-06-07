defmodule Dian.Threads do
  @moduledoc """
  Context for managing saved message threads.

  Threads are per-group collections of messages created by bot commands
  (`/thread:save`, `/thread:append`). Each thread stores one or more messages
  with their original OneBot segments preserved as JSON.
  """

  import Ecto.Query, warn: false
  require Logger

  alias Dian.Repo
  alias Dian.Threads.Message
  alias Dian.Threads.SegmentStore
  alias Dian.Threads.Thread

  @dupe_ttl :timer.seconds(5)

  @doc """
  Fetches a replied-to message via OneBot API, processes its segments,
  and persists it as a new thread with a single message.

  Returns `{:ok, %{thread: %Thread{}, messages: [%Message{}]}}` on success,
  `{:error, :duplicate}` when the same message is being saved concurrently,
  `{:error, :fetch_failed}` when the OneBot API call fails,
  or `{:error, %Ecto.Changeset{}}` on persistence failure.
  """
  def save_replied_message(group_id, creator_id, reply_message_id) do
    dupe_key = "thread:save:#{group_id}:#{reply_message_id}"

    Cachex.transaction(:dian_cache, [dupe_key], fn _ ->
      case Cachex.get(:dian_cache, dupe_key) do
        {:ok, true} ->
          Logger.warning("thread:save dedupe hit",
            group_id: group_id,
            message_id: reply_message_id,
            sender_id: creator_id
          )

          {:error, :duplicate}

        _ ->
          Cachex.put(:dian_cache, dupe_key, true, expire: @dupe_ttl)

          case DianBot.get_msg(reply_message_id) do
            {:ok, msg_data} ->
              msg_attrs = build_msg_attrs(reply_message_id, msg_data)

              case create_thread_with_messages(
                     %{group_id: group_id, creator_id: creator_id},
                     [msg_attrs]
                   ) do
                {:ok, _} = result ->
                  result

                {:error, _} = error ->
                  Cachex.del(:dian_cache, dupe_key)
                  error
              end

            {:error, reason} ->
              Cachex.del(:dian_cache, dupe_key)

              Logger.error("thread:save get_msg failed",
                group_id: group_id,
                message_id: reply_message_id,
                reason: reason
              )

              {:error, :fetch_failed}
          end
      end
    end)
    |> elem(1)
  end

  @doc """
  Fetches a replied-to message via OneBot API and processes its segments
  into a format ready for batch storage.

  Returns `{:ok, msg_attrs_map}` on success or `{:error, :fetch_failed}`
  when the OneBot API call fails.
  """
  def collect_message(reply_message_id) do
    case DianBot.get_msg(reply_message_id) do
      {:ok, msg_data} ->
        msg_attrs = build_msg_attrs(reply_message_id, msg_data)

        Logger.info("thread:append collected",
          message_id: reply_message_id,
          types: msg_attrs.types
        )

        {:ok, msg_attrs}

      {:error, reason} ->
        Logger.error("thread:append collect get_msg failed",
          message_id: reply_message_id,
          reason: reason
        )

        {:error, :fetch_failed}
    end
  end

  @doc """
  Persists a batch of collected messages as a new thread.

  `collected` is a list of message attribute maps produced by
  `collect_message/1`.

  Returns `{:ok, %{thread: %Thread{}, messages: [%Message{}]}}` on success
  or `{:error, %Ecto.Changeset{}}` on persistence failure.
  """
  def batch_save_messages(group_id, creator_id, collected) do
    case create_thread_with_messages(%{group_id: group_id, creator_id: creator_id}, collected) do
      {:ok, %{thread: thread, messages: messages}} ->
        Logger.info("thread:done flush success",
          group_id: group_id,
          creator_id: creator_id,
          count: length(messages)
        )

        {:ok, %{thread: thread, messages: messages}}

      {:error, _changeset} = error ->
        error
    end
  end

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
      with {:ok, thread} <- %Thread{} |> Thread.changeset(attrs) |> repo.insert(),
           {:ok, messages} <- insert_messages(repo, thread, messages_data) do
        {:ok, %{thread: thread, messages: messages}}
      end
    end)
  end

  defp insert_messages(repo, thread, messages_data) do
    messages_data
    |> Enum.reduce_while({:ok, []}, fn msg_attrs, {:ok, acc} ->
      case %Message{thread_id: thread.id}
           |> Message.changeset(msg_attrs)
           |> repo.insert() do
        {:ok, message} -> {:cont, {:ok, [message | acc]}}
        {:error, _changeset} = error -> {:halt, error}
      end
    end)
    |> case do
      {:ok, messages} -> {:ok, Enum.reverse(messages)}
      error -> error
    end
  end

  defp build_msg_attrs(reply_message_id, msg_data) do
    segments = msg_data["message"] || []
    processed = SegmentStore.process_segments(segments)

    sender_id =
      case msg_data do
        %{"sender" => %{"user_id" => uid}} when uid != nil -> to_string(uid)
        _ -> ""
      end

    %{
      raw_message_id: to_string(reply_message_id),
      sender_id: sender_id,
      segments: processed.segments,
      types: processed.types,
      text_content: processed.text_content
    }
  end
end
