defmodule DianWeb.BotTypes do
  use Absinthe.Schema.Notation

  object :bot_queries do
    field :bot, non_null(:bot) do
      resolve fn _, _, _ ->
        {:ok, %{is_online: DianBot.is_online()}}
      end
    end
  end

  object :bot do
    field :is_online, non_null(:boolean)
  end
end
