defmodule DianWeb.Schema do
  use Absinthe.Schema

  alias Dian.Chats

  import_types Absinthe.Type.Custom
  import_types DianWeb.BotTypes
  import_types DianWeb.ChatsTypes
  import_types DianWeb.AccountsTypes

  query do
    import_fields :bot_queries
    import_fields :chats_queries
  end

  def context(ctx) do
    loader = Dataloader.new() |> Dataloader.add_source(Chats, Chats.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
