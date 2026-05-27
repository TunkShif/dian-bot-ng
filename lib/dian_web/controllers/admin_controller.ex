defmodule DianWeb.AdminController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Accounts
  alias Dian.Settings
  alias DianWeb.JSend
  alias DianWeb.Schemas
  alias DianWeb.UserJSON

  action_fallback DianWeb.FallbackController

  tags ["admin"]

  operation :list_users,
    operation_id: "list_users",
    summary: "List all users",
    description: "Returns all registered users. Requires superadmin privileges.",
    responses: [
      ok: {"Users list", "application/json", Schemas.UserListResponse},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      forbidden: {"Superadmin required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :global_settings,
    operation_id: "get_global_settings",
    summary: "Get global settings",
    description: "Returns global system settings including superadmin info.",
    responses: [
      ok: {"Global settings", "application/json", Schemas.GlobalSettingsResponse},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :update_superadmin,
    operation_id: "update_superadmin",
    summary: "Update superadmin",
    description: "Updates the superadmin user. Requires current superadmin privileges.",
    request_body:
      {"Superadmin update params", "application/json", Schemas.SuperadminUpdateRequest,
       required: true},
    responses: [
      ok: {"Superadmin updated", "application/json", Schemas.JSendSuccess},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      forbidden: {"Superadmin required", "application/json", Schemas.JSendMessageFail},
      not_found: {"User not found", "application/json", Schemas.JSendMessageFail}
    ]

  def list_users(conn, _params) do
    require_superadmin!(conn, fn ->
      users = Accounts.list_users()
      JSend.success_json(conn, %{users: UserJSON.many(users)})
    end)
  end

  def global_settings(conn, _params) do
    superadmin_info = Settings.get_superadmin_info()
    group_settings = Settings.list_group_settings()

    JSend.success_json(conn, %{
      superadmin: superadmin_info && UserJSON.one(superadmin_info.user),
      group_count: length(group_settings),
      enabled_group_count: Enum.count(group_settings, & &1.enabled)
    })
  end

  def update_superadmin(conn, %{"user_id" => user_id}) do
    require_superadmin!(conn, fn ->
      case Accounts.get_user(user_id) do
        nil ->
          {:error, :not_found}

        _user ->
          case Settings.maybe_set_superadmin(user_id) do
            {:ok, _settings} -> JSend.success_json(conn, %{updated: true})
            {:error, reason} -> {:error, reason}
          end
      end
    end)
  end

  defp require_superadmin!(conn, callback) do
    if Settings.is_superadmin?(conn.assigns.current_scope.user.id) do
      callback.()
    else
      {:error, :forbidden}
    end
  end
end
