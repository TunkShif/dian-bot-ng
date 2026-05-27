defmodule DianWeb.ExportController do
  use DianWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias Dian.Accounts
  alias Dian.Settings
  alias Dian.Steam
  alias DianWeb.JSend

  action_fallback DianWeb.FallbackController

  tags ["export"]

  operation :export_users,
    operation_id: "export_users",
    summary: "Export users as CSV",
    description: "Exports all registered users as a CSV file. Requires superadmin privileges.",
    responses: [
      ok: {"CSV file", "text/csv", nil},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      forbidden: {"Superadmin required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :export_groups,
    operation_id: "export_groups",
    summary: "Export group settings as CSV",
    description: "Exports all group settings as a CSV file. Requires superadmin privileges.",
    responses: [
      ok: {"CSV file", "text/csv", nil},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      forbidden: {"Superadmin required", "application/json", Schemas.JSendMessageFail}
    ]

  operation :export_steam_players,
    operation_id: "export_steam_players",
    summary: "Export Steam player bindings as CSV",
    description: "Exports all Steam player bindings as a CSV file. Requires superadmin privileges.",
    responses: [
      ok: {"CSV file", "text/csv", nil},
      unauthorized: {"Authentication required", "application/json", Schemas.JSendMessageFail},
      forbidden: {"Superadmin required", "application/json", Schemas.JSendMessageFail}
    ]

  def export_users(conn, _params) do
    require_superadmin!(conn, fn ->
      users = Accounts.list_users()

      csv_header = ["ID", "Email", "Confirmed At", "Created At"]
      csv_rows =
        Enum.map(users, fn user ->
          [
            user.id,
            user.email,
            user.confirmed_at && DateTime.to_iso8601(user.confirmed_at) || "",
            DateTime.to_iso8601(user.inserted_at)
          ]
        end)

      csv_content = generate_csv(csv_header, csv_rows)

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"users_export.csv\"")
      |> send_resp(200, csv_content)
    end)
  end

  def export_groups(conn, _params) do
    require_superadmin!(conn, fn ->
      groups = Settings.list_group_settings()

      csv_header = ["Group ID", "Enabled", "Created At", "Updated At"]
      csv_rows =
        Enum.map(groups, fn group ->
          [
            group.group_id,
            group.enabled,
            DateTime.to_iso8601(group.inserted_at),
            DateTime.to_iso8601(group.updated_at)
          ]
        end)

      csv_content = generate_csv(csv_header, csv_rows)

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"groups_export.csv\"")
      |> send_resp(200, csv_content)
    end)
  end

  def export_steam_players(conn, _params) do
    require_superadmin!(conn, fn ->
      players = Steam.list_steam_players()

      csv_header = ["QQ ID", "Steam ID", "Created At", "Updated At"]
      csv_rows =
        Enum.map(players, fn player ->
          [
            player.qq_id,
            player.steam_id,
            DateTime.to_iso8601(player.inserted_at),
            DateTime.to_iso8601(player.updated_at)
          ]
        end)

      csv_content = generate_csv(csv_header, csv_rows)

      conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header("content-disposition", "attachment; filename=\"steam_players_export.csv\"")
      |> send_resp(200, csv_content)
    end)
  end

  defp generate_csv(header, rows) do
    header_line = Enum.join(header, ",")
    data_lines =
      Enum.map(rows, fn row ->
        row
        |> Enum.map(&escape_csv_field/1)
        |> Enum.join(",")
      end)

    Enum.join([header_line | data_lines], "\n")
  end

  defp escape_csv_field(value) when is_binary(value) do
    if String.contains?(value, [",", "\"", "\n"]) do
      "\"#{String.replace(value, "\"", "\"\"")}\""
    else
      value
    end
  end

  defp escape_csv_field(value), do: to_string(value)

  defp require_superadmin!(conn, callback) do
    if Settings.is_superadmin?(conn.assigns.current_scope.user.id) do
      callback.()
    else
      {:error, :forbidden}
    end
  end
end
