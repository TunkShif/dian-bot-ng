defmodule Dian.Accounts.UserNotifierTest do
  use Dian.DataCase, async: false

  alias Dian.Accounts.UserNotifier

  import Dian.AccountsFixtures

  setup do
    previous_config = Application.get_env(:dian, Dian.Accounts.UserNotifier)

    on_exit(fn ->
      if previous_config do
        Application.put_env(:dian, Dian.Accounts.UserNotifier, previous_config)
      else
        Application.delete_env(:dian, Dian.Accounts.UserNotifier)
      end
    end)

    :ok
  end

  test "uses the configured email sender" do
    Application.put_env(:dian, Dian.Accounts.UserNotifier, sender: "noreply@example.com")

    user = unconfirmed_user_fixture()

    assert {:ok, email} =
             UserNotifier.deliver_update_email_instructions(user, "https://example.com")

    assert email.from == {"Dian", "noreply@example.com"}
  end

  test "falls back to the default email sender" do
    Application.delete_env(:dian, Dian.Accounts.UserNotifier)

    user = unconfirmed_user_fixture()

    assert {:ok, email} =
             UserNotifier.deliver_update_email_instructions(user, "https://example.com")

    assert email.from == {"Dian", "contact@example.com"}
  end
end
