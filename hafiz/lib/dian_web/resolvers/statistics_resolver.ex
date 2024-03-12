defmodule DianWeb.StatisticsResolver do
  alias Dian.Statistics

  def daily_threads(_root, _args, _info) do
    {:ok, Statistics.get_daily_threads_statistics()}
  end
end
