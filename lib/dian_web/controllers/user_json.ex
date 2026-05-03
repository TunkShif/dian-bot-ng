defmodule DianWeb.UserJson do
  alias Dian.Accounts
  alias Dian.Accounts.User

  def one(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      qq_id: Accounts.extract_qq_id_from(user.email)
    }
  end

  def one(_), do: nil
end
