defmodule Dian.Media.RenderedImage do
  @moduledoc """
  Rendered image bytes and metadata returned by `Dian.Media`.
  """

  @enforce_keys [:bytes, :content_type, :width, :height]
  defstruct [:bytes, :content_type, :width, :height]

  @type t :: %__MODULE__{
          bytes: binary(),
          content_type: String.t(),
          width: pos_integer(),
          height: pos_integer()
        }
end
