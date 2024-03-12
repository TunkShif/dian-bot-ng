defmodule Dian.Statistics do
  import Ecto.Query

  alias Dian.Repo
  alias Dian.Chats.{Message, Thread}

  @doc """
  Returns daily thread count in last 6 months.
  """
  def get_daily_threads_statistics() do
    # TODO: fix timezone issue
    last_date = DateTime.utc_now() |> DateTime.add(-(30 * 6), :day)

    Repo.all(
      from thread in Thread,
        where: thread.posted_at > ^last_date,
        group_by: fragment("date_trunc('day', ?)", thread.posted_at),
        order_by: [desc: fragment("date_trunc('day', ?)", thread.posted_at)],
        select: %{date: fragment("date_trunc('day', ?)", thread.posted_at), count: count()}
    )
  end

  def get_user_chats_map(user_ids) do
    query =
      from message in Message,
        where: message.sender_id in ^user_ids,
        group_by: message.sender_id,
        select: {message.sender_id, count(message.id)}

    Repo.all(query)
    |> Map.new()
  end

  def get_user_threads_map(user_ids) do
    query =
      from thread in Thread,
        where: thread.owner_id in ^user_ids,
        group_by: thread.owner_id,
        select: {thread.owner_id, count(thread.id)}

    Repo.all(query)
    |> Map.new()
  end
end
