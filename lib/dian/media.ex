defmodule Dian.Media do
  @moduledoc """
  The Media context.
  """

  alias Dian.Media.RenderedImage
  alias Dian.Media.SvgRenderer

  @type render_error ::
          :invalid_options
          | :invalid_svg
          | :image_too_large
          | :render_timeout
          | {:render_failed, term()}

  @type render_option ::
          {:fonts, [Path.t()]}
          | {:scale, float()}
          | {:timeout, timeout()}

  @spec render_svg(String.t(), [render_option()]) ::
          {:ok, RenderedImage.t()} | {:error, render_error()}
  def render_svg(svg, opts \\ [])

  def render_svg(svg, opts) when is_binary(svg) and is_list(opts) do
    with :ok <- validate_svg(svg),
         {:ok, parsed_opts} <- validate_opts(opts),
         {:ok, font_paths} <- resolve_font_paths(parsed_opts.fonts),
         {:ok, png} <- render_with_task(svg, parsed_opts.timeout, font_paths, parsed_opts.scale) do
      {:ok, to_rendered_image(png)}
    end
  end

  def render_svg(_svg, _opts), do: {:error, :invalid_options}

  defp render_with_task(svg, timeout, font_paths, scale) do
    max_pixels = config(:max_pixels, 16_000_000)
    load_system_fonts = config(:load_system_fonts, true)
    renderer = renderer_module()

    task =
      Task.Supervisor.async_nolink(Dian.Media.RenderTaskSupervisor, fn ->
        renderer.render(svg, font_paths, scale, max_pixels, load_system_fonts)
      end)

    case Task.yield(task, timeout) || Task.shutdown(task, :brutal_kill) do
      {:ok, result} -> normalize_renderer_result(result)
      {:exit, reason} -> {:error, {:render_failed, reason}}
      nil -> {:error, :render_timeout}
    end
  end

  defp normalize_renderer_result({:ok, {bytes, width, height}})
       when is_binary(bytes) and is_integer(width) and width > 0 and is_integer(height) and
              height > 0 do
    {:ok, {bytes, width, height}}
  end

  defp normalize_renderer_result({:error, reason}) do
    {:error, normalize_renderer_error(reason)}
  end

  defp normalize_renderer_result(other), do: {:error, {:render_failed, other}}

  defp normalize_renderer_error(:invalid_svg), do: :invalid_svg
  defp normalize_renderer_error("invalid_svg"), do: :invalid_svg
  defp normalize_renderer_error(:image_too_large), do: :image_too_large
  defp normalize_renderer_error("image_too_large"), do: :image_too_large
  defp normalize_renderer_error(reason), do: {:render_failed, reason}

  defp to_rendered_image({bytes, width, height}) do
    %RenderedImage{
      bytes: bytes,
      content_type: "image/png",
      width: width,
      height: height
    }
  end

  defp validate_svg(svg) do
    max_svg_bytes = config(:max_svg_bytes, 250_000)

    cond do
      byte_size(svg) == 0 ->
        {:error, :invalid_svg}

      byte_size(svg) > max_svg_bytes ->
        {:error, :invalid_options}

      remote_reference?(svg) ->
        {:error, :invalid_options}

      true ->
        :ok
    end
  end

  defp validate_opts(opts) do
    max_scale = config(:max_scale, 4.0)

    defaults = %{
      fonts: [],
      scale: 1.0,
      timeout: config(:default_timeout, 5_000)
    }

    allowed_keys = [:fonts, :scale, :timeout]

    if Keyword.keyword?(opts) and Enum.all?(Keyword.keys(opts), &(&1 in allowed_keys)) do
      parsed_opts =
        Enum.reduce_while(opts, defaults, fn
          {:fonts, fonts}, acc when is_list(fonts) ->
            {:cont, %{acc | fonts: fonts}}

          {:scale, scale}, acc when is_number(scale) ->
            if scale > 0 and scale <= max_scale do
              {:cont, %{acc | scale: scale / 1}}
            else
              {:halt, :invalid}
            end

          {:timeout, timeout}, acc when is_integer(timeout) and timeout > 0 ->
            {:cont, %{acc | timeout: timeout}}

          _, _acc ->
            {:halt, :invalid}
        end)

      case parsed_opts do
        :invalid -> {:error, :invalid_options}
        parsed -> {:ok, parsed}
      end
    else
      {:error, :invalid_options}
    end
  end

  defp resolve_font_paths(extra_fonts) do
    bundled_fonts = bundled_font_paths()
    max_font_count = config(:max_font_count, 8)

    if valid_font_paths?(extra_fonts) and
         length(bundled_fonts) + length(extra_fonts) <= max_font_count do
      {:ok, Enum.uniq(bundled_fonts ++ extra_fonts)}
    else
      {:error, :invalid_options}
    end
  end

  defp bundled_font_paths do
    fonts_dir =
      :dian
      |> Application.app_dir(config(:bundled_fonts_dir, "priv/fonts"))

    if File.dir?(fonts_dir) do
      fonts_dir
      |> Path.join("*")
      |> Path.wildcard()
      |> Enum.filter(&File.regular?/1)
    else
      []
    end
  end

  defp valid_font_paths?(fonts) do
    Enum.all?(fonts, &(is_binary(&1) and File.regular?(&1)))
  end

  defp remote_reference?(svg) do
    Regex.match?(~r/(?:xlink:)?href\s*=\s*["']https?:\/\//i, svg)
  end

  defp renderer_module do
    Application.get_env(:dian, :media_renderer, SvgRenderer)
  end

  defp config(key, default) do
    Application.get_env(:dian, __MODULE__, [])
    |> Keyword.get(key, default)
  end
end
