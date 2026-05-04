defmodule Dian.Steam.SteamPlayerTest do
  use Dian.DataCase

  alias Dian.Steam.SteamPlayer

  describe "changeset/2" do
    test "validates required fields" do
      changeset = SteamPlayer.changeset(%SteamPlayer{}, %{})

      assert %{steam_id: ["can't be blank"], qq_id: ["can't be blank"]} =
               errors_on(changeset)
    end

    test "validates steam_id length" do
      changeset =
        SteamPlayer.changeset(%SteamPlayer{}, %{
          steam_id: "765611",
          qq_id: "12345"
        })

      assert "must be 17 characters" in errors_on(changeset).steam_id
    end

    test "validates steam_id format" do
      changeset =
        SteamPlayer.changeset(%SteamPlayer{}, %{
          steam_id: "12345678901234567",
          qq_id: "12345"
        })

      assert "must be a valid Steam ID" in errors_on(changeset).steam_id
    end

    test "validates qq_id format" do
      changeset =
        SteamPlayer.changeset(%SteamPlayer{}, %{
          steam_id: "76561198000000000",
          qq_id: "abc"
        })

      assert "must be a valid QQ ID" in errors_on(changeset).qq_id
    end

    test "validates qq_id length too short" do
      changeset =
        SteamPlayer.changeset(%SteamPlayer{}, %{
          steam_id: "76561198000000000",
          qq_id: "1234"
        })

      assert "must be 5-13 digits" in errors_on(changeset).qq_id
    end

    test "validates qq_id length too long" do
      changeset =
        SteamPlayer.changeset(%SteamPlayer{}, %{
          steam_id: "76561198000000000",
          qq_id: "12345678901234"
        })

      assert "must be 5-13 digits" in errors_on(changeset).qq_id
    end

    test "accepts valid attributes" do
      changeset =
        SteamPlayer.changeset(%SteamPlayer{}, %{
          steam_id: "76561198000000000",
          qq_id: "12345"
        })

      assert changeset.valid?
    end

    test "accepts optional display_name" do
      changeset =
        SteamPlayer.changeset(%SteamPlayer{}, %{
          steam_id: "76561198000000000",
          qq_id: "12345",
          display_name: "My Steam Name"
        })

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :display_name) == "My Steam Name"
    end
  end
end
