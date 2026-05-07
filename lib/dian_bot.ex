defmodule DianBot do
  alias DianBot.Client
  alias DianBot.Group
  alias DianBot.GroupMember
  alias DianBot.Message

  @type request_opts :: Client.request_opts()
  @type result(data) :: Client.result(data)

  @type group_id :: String.t()
  @type user_id :: String.t()

  @type group :: Group.t()
  @type group_member :: GroupMember.t()
  @type message :: Message.t()
  @type send_message_type :: :group | :private | String.t()

  @spec get_group_info(group_id(), request_opts()) :: result(group())
  def get_group_info(group_id, opts \\ []) do
    params = %{group_id: group_id}

    with {:ok, data} <- Client.request("get_group_info", params, opts) do
      {:ok, Group.build(data)}
    end
  end

  @spec send_msg(
          send_message_type(),
          integer() | String.t(),
          Message.t() | [map()] | String.t(),
          request_opts()
        ) ::
          result(integer())
  def send_msg(message_type, target_id, message, opts \\ []) do
    params =
      %{
        message_type: normalize_message_type(message_type),
        message: Message.to_payload(message)
      }
      |> put_target_id(target_id)

    with {:ok, %{"message_id" => message_id}} <- Client.request("send_msg", params, opts) do
      {:ok, message_id}
    end
  end

  @spec get_group_list(request_opts()) :: result([group()])
  def get_group_list(opts \\ []) do
    with {:ok, data} <- Client.request("get_group_list", %{}, opts) do
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

    with {:ok, data} <- Client.request("get_group_member_info", params, opts) do
      {:ok, GroupMember.build(data)}
    end
  end

  @spec find_group_member_in_groups([group_id()], user_id(), request_opts()) ::
          group_member() | nil
  def find_group_member_in_groups(group_ids, user_id, opts \\ []) when is_list(group_ids) do
    Enum.find_value(group_ids, fn group_id ->
      case get_group_member_info(group_id, user_id, opts) do
        {:ok, member} -> member
        {:error, _reason} -> nil
      end
    end)
  end

  @spec find_group_member_in_any_group(user_id(), request_opts()) :: group_member() | nil
  def find_group_member_in_any_group(user_id, opts \\ []) do
    with {:ok, groups} <- get_group_list(opts) do
      groups
      |> Enum.map(& &1.group_id)
      |> find_group_member_in_groups(user_id, opts)
    else
      {:error, _reason} -> nil
    end
  end

  @spec get_group_member_list(group_id(), request_opts()) :: result([group_member()])
  def get_group_member_list(group_id, opts \\ []) do
    params = %{
      group_id: group_id,
      no_cache: Keyword.get(opts, :no_cache, false)
    }

    with {:ok, data} <- Client.request("get_group_member_list", params, opts) do
      {:ok, Enum.map(data, &GroupMember.build/1)}
    end
  end

  defp normalize_message_type(message_type) when is_atom(message_type),
    do: Atom.to_string(message_type)

  defp normalize_message_type(message_type) when is_binary(message_type), do: message_type

  defp put_target_id(%{message_type: "group"} = params, target_id),
    do: Map.put(params, :group_id, target_id)

  defp put_target_id(%{message_type: "private"} = params, target_id),
    do: Map.put(params, :user_id, target_id)

  defp put_target_id(params, _target_id), do: params
end
