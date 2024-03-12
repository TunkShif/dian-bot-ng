defmodule DianWeb.Middleware.ErrorFormatter do
  @behaviour Absinthe.Middleware

  @impl true
  def call(resolution, _opts) do
    %{resolution | errors: Enum.flat_map(resolution.errors, &format_error/1)}
  end

  def format_error(%Ecto.Changeset{} = changeset) do
    changeset |> DianWeb.ErrorJSON.error() |> Enum.map(fn {key, value} -> "#{key} #{value}" end)
  end

  def format_error(%DianBot.BotError{} = error), do: [error.message]
  def format_error(%Dian.Policy.AuthorizationError{} = error), do: [error.message]
  def format_error(error), do: [error]
end
