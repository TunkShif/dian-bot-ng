defmodule Dian.AI.ClientStub do
  import ExUnit.Assertions

  def generate_text(messages) do
    [system, user] = messages
    assert elem(system, 0) == :system
    assert elem(user, 0) == :user
    assert elem(user, 1) =~ "\"group_id\":\"100\""
    refute elem(user, 1) =~ "\"join_time\""
    refute elem(user, 1) =~ "\"last_sent_time\""
    {:ok, "summary text"}
  end
end
