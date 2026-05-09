defmodule Dian.AI.Client do
  @moduledoc """
  Thin DeepSeek client wrapper built on ReqLLM.
  """

  def generate_text(messages) when is_list(messages) do
    config = Application.get_env(:dian, Dian.AI, [])
    model = Keyword.get(config, :model, %{provider: :deepseek, id: "deepseek-chat"})
    api_key = Keyword.get(config, :deepseek_api_key)
    {system_prompt, prompt} = split_messages(messages)

    case ReqLLM.generate_text(model, prompt, api_key: api_key, system_prompt: system_prompt) do
      {:ok, response} -> {:ok, ReqLLM.Response.text(response)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp split_messages(messages) do
    {system_messages, other_messages} =
      Enum.split_with(messages, fn
        {:system, _content} -> true
        _message -> false
      end)

    system_prompt =
      system_messages
      |> Enum.map(fn {_role, content} -> content end)
      |> Enum.join("\n\n")

    prompt =
      other_messages
      |> Enum.map(fn {_role, content} -> content end)
      |> Enum.join("\n\n")

    {system_prompt, prompt}
  end
end
