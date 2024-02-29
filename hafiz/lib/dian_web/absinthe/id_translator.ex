defmodule DianWeb.Absinthe.IDTranslator do
  @behaviour Absinthe.Relay.Node.IDTranslator

  alias Dian.Sqids

  @impl true
  def to_global_id(type_name, source_id, _schema) do
    source_id = String.to_integer(source_id)
    {:ok, Base.encode64("#{type_name}:#{Sqids.encode(source_id)}")}
  end

  @impl true
  def from_global_id(global_id, _schema) do
    with {:ok, decoded} <- decode_global_id(global_id),
         {:ok, [type_name, hashed_id]} <- split_decoded_id(decoded),
         {:ok, source_id} <- Sqids.decode(hashed_id) do
      {:ok, type_name, source_id}
    end
  end

  defp decode_global_id(global_id) do
    case Base.decode64(global_id) do
      {:ok, decoded} ->
        {:ok, decoded}

      :error ->
        {:error, "Could not decode ID value `#{global_id}'"}
    end
  end

  defp split_decoded_id(decoded) do
    case String.split(decoded, ":", parts: 2) do
      [type_name, hashed_id] when byte_size(type_name) > 0 and byte_size(hashed_id) > 0 ->
        {:ok, [type_name, hashed_id]}

      _ ->
        {:error, "Could not extract value from decoded ID `#{inspect(decoded)}`"}
    end
  end
end
