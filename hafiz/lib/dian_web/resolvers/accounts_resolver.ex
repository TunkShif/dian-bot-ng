defmodule DianWeb.AccountsResolver do
  def fetch_current_user(_root, _args, %{context: context}) do
    {:ok, context[:current_user]}
  end
end
