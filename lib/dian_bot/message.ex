defmodule DianBot.Message do
  @moduledoc """
  Parses inbound NapCat/OneBot message payloads and builds outbound message segments.

  Quick reference:

  - Every segment uses `%{type: "...", data: %{...}}`
  - Common text segment: `%{type: "text", data: %{"text" => binary}}`
  - Mention segment: `%{type: "at", data: %{"qq" => user_id | "all"}}`
  - Reply segment: `%{type: "reply", data: %{"id" => message_id}}`
  - Image segment: `%{type: "image", data: %{"file" => path_or_url_or_base64}}`

  Useful OneBot segment notes from the NapCat docs:

  - Segment payload keys are string-keyed on the wire, even if we build them with atom keys locally.
  - Some segment types have different fields when sending vs receiving.
  - `image.file` is used when sending, while inbound image segments may also contain
    `url`, `summary`, `sub_type`, `file_size`, and marketplace emoji fields.
  - `reply.id` and `at.qq` are strings in the protocol, so the helpers normalize ids
    with `to_string/1`.

  Reference:
  https://napneko.github.io/onebot/segment
  """

  @type segment_data :: %{optional(String.t()) => term()}
  @type segment :: %{type: String.t(), data: segment_data()}
  @type sender :: %{
          optional(:user_id) => integer() | nil,
          optional(:nickname) => String.t() | nil,
          optional(:sex) => String.t() | nil,
          optional(:age) => integer() | nil,
          optional(:card) => String.t() | nil,
          optional(:level) => String.t() | nil,
          optional(:role) => String.t() | nil
        }

  @type t :: %__MODULE__{
          real_seq: String.t() | nil,
          temp_source: integer() | nil,
          message_sent_type: String.t() | nil,
          target_id: integer() | nil,
          self_id: integer() | nil,
          time: integer() | nil,
          message_id: integer() | nil,
          message_seq: integer() | nil,
          real_id: integer() | nil,
          user_id: integer() | nil,
          group_id: integer() | nil,
          group_name: String.t() | nil,
          message_type: String.t() | nil,
          sub_type: String.t() | nil,
          sender: sender() | nil,
          message: [segment()],
          message_format: String.t() | nil,
          raw_message: String.t() | nil,
          font: String.t() | nil,
          post_type: String.t() | nil,
          raw: String.t() | nil
        }

  defstruct real_seq: nil,
            temp_source: nil,
            message_sent_type: nil,
            target_id: nil,
            self_id: nil,
            time: nil,
            message_id: nil,
            message_seq: nil,
            real_id: nil,
            user_id: nil,
            group_id: nil,
            group_name: nil,
            message_type: nil,
            sub_type: nil,
            sender: nil,
            message: [],
            message_format: nil,
            raw_message: nil,
            font: nil,
            post_type: nil,
            raw: nil

  @spec build(map()) :: t()
  def build(data) when is_map(data) do
    %__MODULE__{
      real_seq: data["real_seq"],
      temp_source: data["temp_source"],
      message_sent_type: data["message_sent_type"],
      target_id: data["target_id"],
      self_id: data["self_id"],
      time: data["time"],
      message_id: data["message_id"],
      message_seq: data["message_seq"],
      real_id: data["real_id"],
      user_id: data["user_id"],
      group_id: data["group_id"],
      group_name: data["group_name"],
      message_type: data["message_type"],
      sub_type: data["sub_type"],
      sender: build_sender(data["sender"]),
      message: build_segments(data["message"]),
      message_format: data["message_format"],
      raw_message: data["raw_message"],
      font: data["font"],
      post_type: data["post_type"],
      raw: data["raw"]
    }
  end

  @spec segment(atom() | String.t(), map()) :: segment()
  def segment(type, data) when is_map(data) do
    %{
      type: to_string(type),
      data: stringify_keys(data)
    }
  end

  @spec text(String.t()) :: segment()
  def text(text) when is_binary(text) do
    segment(:text, %{text: text})
  end

  @spec at(String.t() | integer()) :: segment()
  def at(user_id) do
    segment(:at, %{qq: to_string(user_id)})
  end

  @spec reply(String.t() | integer()) :: segment()
  def reply(message_id) do
    segment(:reply, %{id: to_string(message_id)})
  end

  @spec image(String.t()) :: segment()
  def image(file) when is_binary(file) do
    segment(:image, %{file: file})
  end

  @spec to_payload(t() | segment() | [t() | segment() | String.t() | map()] | String.t()) ::
          [map()]
  def to_payload(%__MODULE__{message: message}), do: to_payload(message)
  def to_payload(message) when is_binary(message), do: [text(message) |> dump_segment()]
  def to_payload(message) when is_list(message), do: Enum.map(message, &dump_segment/1)
  def to_payload(%{} = segment), do: [dump_segment(segment)]

  defp build_sender(%{} = sender) do
    %{
      user_id: sender["user_id"],
      nickname: sender["nickname"],
      sex: sender["sex"],
      age: sender["age"],
      card: sender["card"],
      level: sender["level"],
      role: sender["role"]
    }
  end

  defp build_sender(_), do: nil

  defp build_segments(segments) when is_list(segments) do
    Enum.map(segments, fn
      %{} = segment -> build_segment(segment)
      _other -> nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp build_segments(_), do: []

  defp build_segment(%{} = segment) do
    type = Map.get(segment, "type") || Map.get(segment, :type)
    data = Map.get(segment, "data") || Map.get(segment, :data) || %{}

    %{type: to_string(type), data: stringify_keys(data)}
  end

  defp dump_segment(%{type: type, data: data}) when is_map(data) do
    %{
      "type" => to_string(type),
      "data" => stringify_keys(data)
    }
  end

  defp dump_segment(%{"type" => type, "data" => data}) when is_map(data) do
    %{
      "type" => to_string(type),
      "data" => stringify_keys(data)
    }
  end

  defp dump_segment(message) when is_binary(message), do: text(message) |> dump_segment()

  defp stringify_keys(map) when is_map(map) do
    Map.new(map, fn {key, value} ->
      {to_string(key), value}
    end)
  end
end
