defmodule DianWeb.Middleware.Auth do
  @behaviour Absinthe.Middleware

  alias Dian.Chats.User

  @impl true
  def call(resolution, _opts) do
    case resolution.context do
      %{current_user: %User{}} -> resolution
      _ -> Absinthe.Resolution.put_result(resolution, {:error, "unauthenticated"})
    end
  end
end
