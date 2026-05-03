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

  ## Authentication routes
  scope "/redirects/", DianWeb do
    pipe_through [:browser]

    get "/users/login/:token", UserSessionController, :confirm
    delete "/users/logout", UserSessionController, :delete
  end

  ## Internal API
  scope "/api", DianWeb do
    pipe_through :api

    post "/users/register", UserRegistrationController, :create
    post "/users/login", UserSessionController, :create
    get "/users/me", UserSessionController, :show

    post "/passkeys/login/begin", PasskeySessionController, :begin
    post "/passkeys/login/complete", PasskeySessionController, :complete
  end

  scope "/api", DianWeb do
    pipe_through [:api, :require_authenticated_user]

    post "/passkeys/registration/begin", PasskeyRegistrationController, :begin
    post "/passkeys/registration/complete", PasskeyRegistrationController, :complete
    get "/passkeys", PasskeySessionController, :index
    patch "/passkeys/:id", PasskeySessionController, :update
    delete "/passkeys/:id", PasskeySessionController, :delete
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
