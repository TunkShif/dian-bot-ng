defmodule DianWeb.StatisticsTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias DianWeb.StatisticsResolver

  object :statistics_queries do
    field :daily_threads_statistics, non_null(list_of(non_null(:daily_threads_statistics))) do
      resolve &StatisticsResolver.daily_threads/3
    end
  end

  object :daily_threads_statistics do
    field :date, non_null(:naive_datetime)
    field :count, non_null(:integer)
  end
end
