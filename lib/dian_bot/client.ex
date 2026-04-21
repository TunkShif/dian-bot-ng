defmodule DianBot.Client do
  @callback request(action :: String.t(), params :: map(), opts :: keyword()) ::
              {:ok, term()} | {:error, term()}

  # TODO: if it's a better idea to use `defdelegate`?
  def request(action, params \\ %{}, opts \\ []) do
    impl().request(action, params, opts)
  end

  def get_group_list(params, opts \\ []), do: request("get_group_list", params, opts)

  def impl do
    Application.fetch_env!(:dian, DianBot.Bot)
    |> Keyword.get(:client, DianBot.Client.Default)
  end
end
