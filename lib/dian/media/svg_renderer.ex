defmodule Dian.Media.SvgRenderer do
  @moduledoc false

  use Rustler, otp_app: :dian, crate: :dian_media

  @spec render(String.t(), [String.t()], float(), pos_integer(), boolean()) ::
          {:ok, {binary(), pos_integer(), pos_integer()}} | {:error, term()}
  def render(_svg, _font_paths, _scale, _max_pixels, _load_system_fonts),
    do: :erlang.nif_error(:nif_not_loaded)
end
