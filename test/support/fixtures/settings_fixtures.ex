defmodule Dian.SettingsFixtures do
  @moduledoc """
  This module defines test helpers for creating settings data.
  """

  alias Dian.Repo
  alias Dian.Settings.{GlobalSetting, GroupSetting}

  def global_setting_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{superadmin_user_id: 1})

    %GlobalSetting{}
    |> GlobalSetting.superadmin_changeset(attrs)
    |> Repo.insert!()
  end

  def enabled_group_setting_fixture(attrs \\ %{}) do
    attrs = Enum.into(attrs, %{group_id: "test-group", enabled: true})

    %GroupSetting{}
    |> GroupSetting.changeset(attrs)
    |> Repo.insert!()
  end

  def stub_bot_group_member_info(group_id \\ "test-group") do
    enabled_group_setting_fixture(group_id: group_id)

    Mox.stub(DianBot.Client.Mock, :request, fn
      "get_group_member_info", %{group_id: ^group_id, user_id: qq_id, no_cache: false}, opts
      when is_list(opts) ->
        {:ok,
         %{
           "group_id" => group_id,
           "user_id" => String.to_integer(qq_id),
           "nickname" => "test member",
           "card" => "",
           "join_time" => 0,
           "last_sent_time" => 0,
           "is_robot" => false,
           "role" => "member",
           "title" => ""
         }}

      _action, _params, _opts ->
        {:error, :unexpected_request}
    end)
  end
end
