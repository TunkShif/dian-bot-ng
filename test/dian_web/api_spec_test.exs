defmodule DianWeb.APISpecTest do
  use ExUnit.Case, async: true

  test "documents passkey endpoints" do
    spec = DianWeb.APISpec.spec()

    assert Map.has_key?(spec.paths, "/api/passkeys/login/begin")
    assert Map.has_key?(spec.paths, "/api/passkeys/login/complete")
    assert Map.has_key?(spec.paths, "/api/passkeys/registration/begin")
    assert Map.has_key?(spec.paths, "/api/passkeys/registration/complete")
    assert Map.has_key?(spec.paths, "/api/passkeys")
    assert Map.has_key?(spec.paths, "/api/passkeys/{id}")

    assert spec.paths["/api/passkeys/login/begin"].post.operationId == "begin_passkey_login"
    assert spec.paths["/api/passkeys"].get.operationId == "list_passkeys"
    assert spec.paths["/api/passkeys/{id}"].patch.operationId == "update_passkey"
    assert spec.paths["/api/passkeys/{id}"].delete.operationId == "delete_passkey"
  end

  test "documents group endpoints with concrete response schemas" do
    spec = DianWeb.APISpec.spec()

    assert Map.has_key?(spec.paths, "/api/groups")
    assert Map.has_key?(spec.paths, "/api/groups/{id}")

    assert spec.paths["/api/groups"].get.operationId == "list_groups"
    assert spec.paths["/api/groups/{id}"].get.operationId == "show_group"
    assert spec.paths["/api/groups/{id}"].patch.operationId == "update_group"

    assert get_response_schema_ref(spec, "/api/groups", :get, 200) ==
             "#/components/schemas/GroupListResponse"

    assert get_response_schema_ref(spec, "/api/groups/{id}", :get, 200) ==
             "#/components/schemas/GroupResponse"

    assert get_response_schema_ref(spec, "/api/groups/{id}", :patch, 200) ==
             "#/components/schemas/GroupSettingsResponse"

    group_list_schema = spec.components.schemas["GroupListResponse"]
    group_schema = spec.components.schemas["GroupResponse"]
    settings_schema = spec.components.schemas["GroupSettingsResponse"]

    assert get_in(group_list_schema.properties, [
             :data,
             Access.key!(:properties),
             :groups,
             Access.key!(:items),
             Access.key!(:properties)
           ])
           |> Map.keys()
           |> Enum.sort() == [
             :enabled,
             :group_id,
             :group_name,
             :group_remark,
             :is_admin,
             :member_count
           ]

    assert get_in(group_schema.properties, [
             :data,
             Access.key!(:properties),
             :group,
             Access.key!(:properties),
             :members,
             Access.key!(:items),
             Access.key!(:properties)
           ])
           |> Map.keys()
           |> Enum.sort() == [
             :display_name,
             :group_id,
             :is_robot,
             :join_time,
             :last_sent_time,
             :nickname,
             :role,
             :title,
             :user_id
           ]

    assert get_in(settings_schema.properties, [
             :data,
             Access.key!(:properties),
             :group,
             Access.key!(:properties)
           ])
           |> Map.keys()
           |> Enum.sort() == [:enabled, :id]
  end

  defp get_response_schema_ref(spec, path, method, status) do
    spec.paths
    |> get_in([
      path,
      Access.key!(method),
      Access.key!(:responses),
      status,
      Access.key!(:content),
      "application/json",
      Access.key!(:schema)
    ])
    |> Map.fetch!(:"$ref")
  end
end
