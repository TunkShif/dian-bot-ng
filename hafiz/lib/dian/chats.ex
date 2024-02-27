defmodule Dian.Chats do
  import Ecto.Query

  alias Dian.Repo
  alias DianBot.Schemas.Event
  alias DianBot.Schemas.User, as: BotUser
  alias DianBot.Schemas.Group, as: BotGroup
  alias DianBot.Schemas.Message, as: BotMessage
  alias Dian.Chats.{User, Group, Message, Thread}

  def data, do: Dataloader.Ecto.new(Dian.Repo, query: &query/2)
  def query(queryable, _params), do: queryable

  def list_threads() do
    Repo.all(from thread in Thread, limit: 10, order_by: [desc: thread.posted_at], select: thread)
  end

  def list_user_threads_query(user_id) do
    from thread in Thread, where: [owner_id: ^user_id], order_by: [desc: thread.posted_at]
  end

  def get_user_statistics(user_id) do
    chats_query = from message in Message, where: [sender_id: ^user_id]
    threads_query = from thread in Thread, where: [owner_id: ^user_id]

    %{
      chats: Repo.aggregate(chats_query, :count),
      threads: Repo.aggregate(threads_query, :count),
      followers: 0 # TODO: follower
    }
  end

  def create_thread(%Event{} = event) do
    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.run(:owner, fn _repo, _changes -> get_or_create_user(event.owner) end)
      |> Ecto.Multi.run(:group, fn _repo, _changes -> get_or_create_group(event.group) end)
      |> Ecto.Multi.run(:bot_messages, fn _repo, _changes -> BotMessage.prepare(event.message) end)
      |> Ecto.Multi.run(:messages, fn repo, %{bot_messages: bot_messages} ->
        try do
          messages =
            for message <- bot_messages do
              sender = get_or_create_user!(message.sender)

              Ecto.build_assoc(sender, :messages)
              |> Message.changeset(Map.take(message, [:raw_text, :content, :sent_at]))
              |> repo.insert!()
            end

          {:ok, messages}
        rescue
          error -> {:error, error}
        end
      end)
      |> Ecto.Multi.run(:thread, fn repo, %{owner: owner, group: group, messages: messages} ->
        Thread.changeset(%Thread{}, %{posted_at: event.marked_at})
        |> Ecto.Changeset.put_assoc(:owner, owner)
        |> Ecto.Changeset.put_assoc(:group, group)
        |> Ecto.Changeset.put_assoc(:messages, messages)
        |> repo.insert()
      end)

    case Repo.transaction(multi) do
      {:ok, %{thread: thread}} ->
        {:ok, thread}

      {:error, failed_operation, failed_value, changes} ->
        {:error, {failed_operation, failed_value, changes}}
    end
  end

  def create_user(%BotUser{} = user_params) do
    User.create_changeset(%User{}, user_params)
    |> Repo.insert()
  end

  def create_group(%BotGroup{} = group_params) do
    Group.create_changeset(%Group{}, group_params)
    |> Repo.insert()
  end

  def get_or_create_user!(params) do
    case get_or_create_user(params) do
      {:ok, user} -> user
      {:error, error} -> raise error
    end
  end

  def get_or_create_user(qid) when is_binary(qid) do
    case Repo.get_by(User, qid: qid) do
      nil ->
        with {:ok, user_params} <- DianBot.get_user(qid) do
          create_user(user_params)
        end

      user ->
        {:ok, user}
    end
  end

  def get_or_create_user(%BotUser{} = user_params) do
    case Repo.get_by(User, qid: user_params.qid) do
      nil -> create_user(user_params)
      user -> {:ok, user}
    end
  end

  def get_or_create_group(gid) when is_binary(gid) do
    case Repo.get_by(Group, gid: gid) do
      nil ->
        with {:ok, group_params} <- DianBot.get_group(gid) do
          create_group(group_params)
        end

      group ->
        {:ok, group}
    end
  end

  def get_or_create_group(%BotGroup{} = group_params) do
    case Repo.get_by(Group, gid: group_params.gid) do
      nil -> create_group(group_params)
      group -> {:ok, group}
    end
  end
end
