defmodule Dian.Accounts.PasskeyTest do
  use Dian.DataCase

  import Dian.AccountsFixtures

  alias Dian.Accounts.Passkey

  describe "registration_changeset/3" do
    test "sets credential fields and user ownership" do
      user = user_fixture()
      scope = user_scope_fixture(user)

      changeset =
        Passkey.registration_changeset(
          %Passkey{},
          %{
            label: "Laptop",
            credential_id: <<1, 2, 3>>,
            user_handle: <<4, 5, 6>>,
            public_key: <<7, 8, 9>>,
            sign_count: 1
          },
          scope
        )

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :user_id) == user.id
    end
  end

  describe "label_changeset/2" do
    test "only permits label updates" do
      changeset =
        Passkey.label_changeset(%Passkey{label: "Old"}, %{
          "label" => "New",
          "credential_id" => <<1, 2, 3>>
        })

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :label) == "New"
      refute Ecto.Changeset.get_change(changeset, :credential_id)
    end
  end

  describe "usage_changeset/2" do
    test "updates last used time and sign count" do
      last_used_at = DateTime.utc_now(:second)

      changeset =
        Passkey.usage_changeset(%Passkey{}, %{
          last_used_at: last_used_at,
          sign_count: 2
        })

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :last_used_at) == last_used_at
      assert Ecto.Changeset.get_change(changeset, :sign_count) == 2
    end
  end
end
