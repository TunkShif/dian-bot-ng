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
end
