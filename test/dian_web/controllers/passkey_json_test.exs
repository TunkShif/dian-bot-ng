defmodule DianWeb.PasskeyJSONTest do
  use Dian.DataCase

  alias Dian.Accounts.Passkey
  alias DianWeb.PasskeyJSON

  test "serializes one passkey" do
    inserted_at = ~U[2026-05-04 01:02:03Z]
    updated_at = ~U[2026-05-04 02:03:04Z]
    last_used_at = ~U[2026-05-04 03:04:05Z]

    passkey = %Passkey{
      id: 123,
      label: "Security key",
      last_used_at: last_used_at,
      inserted_at: inserted_at,
      updated_at: updated_at
    }

    assert PasskeyJSON.one(passkey) == %{
             id: 123,
             label: "Security key",
             last_used_at: last_used_at,
             inserted_at: inserted_at,
             updated_at: updated_at
           }
  end
end
