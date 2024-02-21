defmodule DianWeb.Router do
  use DianWeb, :router

  import DianWeb.Auth

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_current_user
  end

  pipeline :graphql do
    plug :fetch_current_user
    plug :put_user_context
  end

  scope "/api", DianWeb do
    pipe_through :api

    post "/auth/login", SessionController, :create
    delete "/auth/logout", SessionController, :delete
  end

  scope "/webhooks", DianWeb do
    pipe_through :api

    post "/event", WebhookController, :event
  end

  scope "/graphql" do
    pipe_through :graphql

    forward "/", Absinthe.Plug, schema: DianWeb.Schema
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:dian, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: DianWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview

      get "/explorer", DianWeb.ExplorerController, :index
      forward "/graphiql", Absinthe.Plug.GraphiQL, schema: DianWeb.Schema
    end
  end
end
