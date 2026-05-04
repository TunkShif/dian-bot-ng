defmodule DianWeb.PasskeyJSON do
  def one(passkey) do
    %{
      id: passkey.id,
      label: passkey.label,
      last_used_at: passkey.last_used_at,
      inserted_at: passkey.inserted_at,
      updated_at: passkey.updated_at
    }
  end

  def many(passkeys), do: Enum.map(passkeys, &one/1)
end
