defmodule DianBot.Coucou do
  @moduledoc """
  Message parser with CQ code support.
  """

  defmodule Parser do
    @moduledoc false

    import NimbleParsec

    comma = string(",")
    equal = string("=")
    closing = string("]")

    ident = ascii_string([?a..?z, ?A..?Z], min: 1)

    pair = ident |> ignore(equal) |> concat(utf8_string([not: ?,, not: ?]], min: 1)) |> wrap()

    pairs =
      choice([pair, ignore(comma)])
      |> repeat()
      |> map({List, :to_tuple, []})
      |> reduce({Map, :new, []})

    type = unwrap_and_tag(ident, :type)
    data = unwrap_and_tag(pairs, :data)

    code =
      ignore(string("[CQ:"))
      |> concat(type)
      |> ignore(comma)
      |> concat(data)
      |> concat(ignore(closing))
      |> reduce({Map, :new, []})

    text = utf8_string([{:not, ?[}, {:not, ?]}], min: 1) |> reduce({:wrap_text, []})

    message = choice([code, text]) |> repeat()

    defparsec(:parse, message)

    defp wrap_text([text]), do: %{type: "text", data: text}
  end

  @type data :: String.t() | %{String.t() => String.t()}
  @type result :: [%{type: String.t(), data: data()}]

  @doc ~S"""
  Parse a message text containing CQ code.

  ## Examples
      iex> DianBot.Coucou.parse("[CQ:at,qq=8964]foobar")
      [%{type: "at", data: %{"qq" => "8964"}}, %{type: "text", data: "foobar"}]
  """
  @spec parse(String.t()) :: result()
  def parse(source) do
    {:ok, result, _rest, _context, _position, _byte_offset} = Parser.parse(source)
    result
  end
end
