defmodule DianWeb.HelperResolver do
  @doc """
  Resolve a hashed id.
  """
  def hashed_id(root, _args, _info) do
    {:ok, Dian.Sqids.encode!([root.id])}
  end
end
