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

    assert email.from == {"", "noreply@example.com"}
  end

  test "accepts a configured sender with display name" do
    Application.put_env(
      :dian,
      Dian.Accounts.UserNotifier,
      sender: "Support Team <noreply@example.com>"
    )

    user = unconfirmed_user_fixture()

    assert {:ok, email} =
             UserNotifier.deliver_update_email_instructions(user, "https://example.com")

    assert email.from == {"", "Support Team <noreply@example.com>"}
  end

  test "raises for an invalid configured sender" do
    Application.put_env(:dian, Dian.Accounts.UserNotifier, sender: "\"noreply@example.com\"")

    user = unconfirmed_user_fixture()

    assert_raise ArgumentError,
                 ~r/USER_NOTIFIER_EMAIL_SENDER must be a valid email@example.com or Name <email@example.com> value/,
                 fn ->
                   UserNotifier.deliver_update_email_instructions(user, "https://example.com")
                 end
  end

  test "falls back to the default email sender" do
    Application.delete_env(:dian, Dian.Accounts.UserNotifier)

    user = unconfirmed_user_fixture()

    assert {:ok, email} =
             UserNotifier.deliver_update_email_instructions(user, "https://example.com")

    assert email.from == {"", "contact@example.com"}
  end
end
