defmodule DianBot.Client do
  alias DianBot.Group
  alias DianBot.GroupMember

  @type action :: String.t()
  @type params :: map()
  @type request_opts :: keyword()
  @type result(data) :: {:ok, data} | {:error, term()}

  @type group_id :: String.t()
  @type user_id :: String.t()

  @type group :: Group.t()
  @type group_member :: GroupMember.t()

  @callback request(action(), params(), request_opts()) :: result(term())

  @spec request(action(), params(), request_opts()) :: result(term())
  def request(action, params \\ %{}, opts \\ []) do
    impl().request(action, params, opts)
  end

  @spec get_group_info(group_id(), request_opts()) :: result(group())
  def get_group_info(group_id, opts \\ []) do
    params = %{group_id: group_id}

    with {:ok, data} <- request("get_group_info", params, opts) do
      {:ok, Group.build(data)}
    end
  end

  @spec get_group_list(request_opts()) :: result([group()])
  def get_group_list(opts \\ []) do
    with {:ok, data} <- request("get_group_list", %{}, opts) do
      {:ok, Enum.map(data, &Group.build/1)}
    end
  end

  @spec get_group_member_info(group_id(), user_id(), request_opts()) :: result(group_member())
  def get_group_member_info(group_id, user_id, opts \\ []) do
    params = %{
      group_id: group_id,
      user_id: user_id,
      no_cache: Keyword.get(opts, :no_cache, false)
    }

    with {:ok, data} <- request("get_group_member_info", params, opts) do
      {:ok, GroupMember.build(data)}
    end
  end

  @spec get_group_member_list(group_id(), request_opts()) :: result([group_member()])
  def get_group_member_list(group_id, opts \\ []) do
    params = %{
      group_id: group_id,
      no_cache: Keyword.get(opts, :no_cache, false)
    }

    with {:ok, data} <- request("get_group_member_list", params, opts) do
      {:ok, Enum.map(data, &GroupMember.build/1)}
    end
  end

  @spec impl() :: module()
  def impl do
    Application.fetch_env!(:dian, DianBot.Bot)
    |> Keyword.get(:client, DianBot.Client.Default)
  end
end
