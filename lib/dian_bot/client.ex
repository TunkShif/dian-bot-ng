defmodule DianBot.Client do
  @type action :: String.t()
  @type params :: map()
  @type request_opts :: keyword()
  @type result(data) :: {:ok, data} | {:error, term()}

  @callback request(action(), params(), request_opts()) :: result(term())

  @spec request(action(), params(), request_opts()) :: result(term())
  def request(action, params \\ %{}, opts \\ []) do
    impl().request(action, params, opts)
  end

  @spec impl() :: module()
  def impl do
    Application.fetch_env!(:dian, DianBot.Bot)
    |> Keyword.get(:client, DianBot.Client.WebSocket)
  end
end
