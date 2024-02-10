defmodule DianWeb.Router do
  use DianWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/webhooks", DianWeb do
    pipe_through :api

    post "/event", WebhookController, :event
  end

  forward "/graphql", Absinthe.Plug, schema: DianWeb.Schema

  if Application.compile_env(:dian, :dev_routes) do
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
