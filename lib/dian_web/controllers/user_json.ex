defmodule DianWeb.UserJSON do
  alias Dian.Accounts.User

  def one(%User{} = user) do
    %{
      id: user.id,
      email: user.email,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at
    }
  end

  def many(users) when is_list(users) do
    Enum.map(users, &one/1)
  end
end
