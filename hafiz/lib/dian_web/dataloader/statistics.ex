defmodule DianWeb.Dataloader.Statistics do
  alias Dian.Statistics

  def data(), do: Dataloader.KV.new(&query/2)

  def query(_batch_key, users) do
    user_ids = for user <- users, do: user.id
    chats_count_map = Statistics.get_user_chats_map(user_ids)
    threads_count_map = Statistics.get_user_threads_map(user_ids)

    for user <- users, into: %{} do
      statistics = %{
        chats: chats_count_map[user.id] || 0,
        threads: threads_count_map[user.id] || 0,
        followers: 0
      }

      {user, statistics}
    end
  end
end
