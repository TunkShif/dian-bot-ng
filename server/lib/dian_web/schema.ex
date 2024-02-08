defmodule DianWeb.Schema do
  use Absinthe.Schema

  import_types DianWeb.BotTypes
  import_types DianWeb.ChatsTypes
  import_types DianWeb.AccountTypes

  query do
    import_fields :bot_queries
    import_fields :chats_queries
  end
end
