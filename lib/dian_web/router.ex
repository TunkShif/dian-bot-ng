defmodule DianWeb.Router do
  use DianWeb, :router

  import DianWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DianWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug OpenApiSpex.Plug.PutApiSpec, module: DianWeb.APISpec
  end

  pipeline :api_rate_limited do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
    plug OpenApiSpex.Plug.PutApiSpec, module: DianWeb.APISpec
    plug DianWeb.Plugs.RateLimit, window_ms: :timer.minutes(15), max_requests: 5
  end

  ## Authentication routes
  scope "/redirects/", DianWeb do
    pipe_through [:browser]

    get "/users/login/:token", UserSessionController, :confirm
    delete "/users/logout", UserSessionController, :delete
  end

  ## Internal API (rate-limited auth endpoints)
  scope "/api", DianWeb do
    pipe_through :api_rate_limited

    post "/users/register", UserRegistrationController, :create
    post "/users/login", UserSessionController, :create

    post "/passkeys/login/begin", PasskeySessionController, :begin
    post "/passkeys/login/complete", PasskeySessionController, :complete
  end

  ## Internal API (authenticated endpoints)
  scope "/api", DianWeb do
    pipe_through :api

    get "/users/me", UserSessionController, :show
  end

  scope "/api", DianWeb do
    pipe_through [:api, :require_authenticated_user]

    post "/passkeys/registration/begin", PasskeyRegistrationController, :begin
    post "/passkeys/registration/complete", PasskeyRegistrationController, :complete
    get "/passkeys", PasskeySessionController, :index
    patch "/passkeys/:id", PasskeySessionController, :update
    delete "/passkeys/:id", PasskeySessionController, :delete

    get "/groups", GroupController, :index
    get "/groups/:id", GroupController, :show
    patch "/groups/:id", GroupController, :update

    patch "/users/settings", UserSettingsController, :update

    get "/steam/players/:steam_id", SteamPlayerController, :show_by_steam_id
    get "/steam/players/by-qq/:qq_id", SteamPlayerController, :show_by_qq_id
    put "/steam/players/self", SteamPlayerController, :bind_self
    delete "/steam/players/self", SteamPlayerController, :unbind_self
    put "/steam/players/group-members/:group_id/:qq_id", SteamPlayerController, :bind_member

    # Admin endpoints
    get "/admin/users", AdminController, :list_users
    get "/admin/settings", AdminController, :global_settings
    put "/admin/superadmin", AdminController, :update_superadmin

    # Export endpoints
    get "/export/users", ExportController, :export_users
    get "/export/groups", ExportController, :export_groups
    get "/export/steam-players", ExportController, :export_steam_players
  end

  ## SPA entrypoint
  scope "/", DianWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/app/*path", PageController, :home
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
      pipe_through :browser

      live_dashboard "/dashboard", metrics: DianWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
      get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/dev/openapi"
    end

    # Only serve the internal openapi spec when in development
    scope "/dev" do
      pipe_through :api

      get "/openapi", OpenApiSpex.Plug.RenderSpec, []
    end
  end
end
