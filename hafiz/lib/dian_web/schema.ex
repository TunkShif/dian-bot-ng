defmodule DianWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias Dian.Chats
  alias DianWeb.NodeResolver

  import_types Absinthe.Type.Custom
  import_types DianWeb.NodeTypes
  import_types DianWeb.BotTypes
  import_types DianWeb.ChatsTypes
  import_types DianWeb.AccountsTypes

  query do
    import_fields :me_queries
    import_fields :bot_queries
    import_fields :chats_queries

    node field do
      resolve &NodeResolver.resolve_node/2
    end
  end

  def context(ctx) do
    loader = Dataloader.new() |> Dataloader.add_source(Chats, Chats.data())

    Map.put(ctx, :loader, loader)
  end

  def middleware(middleware, _field, _object) do
    [DianWeb.Middleware.Auth] ++ middleware
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
