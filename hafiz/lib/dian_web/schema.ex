defmodule DianWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, flavor: :modern, global_id_translator: DianWeb.Absinthe.IDTranslator

  alias DianWeb.NodeResolver

  import_types Absinthe.Type.Custom
  import_types DianWeb.NodeTypes
  import_types DianWeb.BotTypes
  import_types DianWeb.ChatsTypes
  import_types DianWeb.AccountsTypes
  import_types DianWeb.SystemsTypes
  import_types DianWeb.StatisticsTypes
  import_types DianWeb.TrackerTypes

  query do
    import_fields :bot_queries
    import_fields :accounts_queries
    import_fields :chats_queries
    import_fields :systems_queries
    import_fields :statistics_queries
    import_fields :tracker_queries

    node field do
      resolve &NodeResolver.resolve_node/2
    end
  end

  mutation do
    import_fields :accounts_mutations
    import_fields :systems_mutations
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Chats, Dian.Chats.data())
      |> Dataloader.add_source(Statistics, DianWeb.Dataloader.Statistics.data())

    Map.put(ctx, :loader, loader)
  end

  def middleware(middleware, field, _object) do
    meta = Absinthe.Type.meta(field)

    middleware =
      unless meta[:skip_auth] do
        [DianWeb.Middleware.Auth | middleware]
      else
        middleware
      end

    middleware ++ [DianWeb.Middleware.ErrorFormatter]
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
