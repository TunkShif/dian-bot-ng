defmodule DianWeb.StatisticsResolver do
  alias Dian.Chats

  def daily_threads(_root, _args, _info) do
    {:ok, Chats.get_daily_threads_statistics()}
  end
end
