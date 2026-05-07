defmodule Dian.MediaTest do
  use ExUnit.Case, async: false

  alias Dian.Media
  alias Dian.Media.RenderedImage

  defmodule SlowRenderer do
    def render(_svg, _font_paths, _scale, _max_pixels, _load_system_fonts) do
      Process.sleep(50)
      {:ok, {<<137, 80, 78, 71>>, 1, 1}}
    end
  end

  defmodule ErrorRenderer do
    def render(_svg, _font_paths, _scale, _max_pixels, _load_system_fonts) do
      {:error, "image_too_large"}
    end
  end

  setup do
    previous_renderer = Application.get_env(:dian, :media_renderer)
    previous_media_config = Application.get_env(:dian, Dian.Media, [])

    on_exit(fn ->
      if previous_renderer do
        Application.put_env(:dian, :media_renderer, previous_renderer)
      else
        Application.delete_env(:dian, :media_renderer)
      end

      Application.put_env(:dian, Dian.Media, previous_media_config)
    end)

    :ok
  end

  defp fixture_font_path(name) do
    Path.expand("../support/fixtures/fonts/#{name}", __DIR__)
  end

  describe "render_svg/2" do
    test "renders a simple svg into a png image struct" do
      svg = """
      <svg xmlns="http://www.w3.org/2000/svg" width="12" height="8" viewBox="0 0 12 8">
        <rect width="12" height="8" fill="#ff0000" />
      </svg>
      """

      assert {:ok,
              %RenderedImage{
                bytes: <<0x89, 0x50, 0x4E, 0x47, _::binary>>,
                content_type: "image/png",
                width: 12,
                height: 8
              }} = Media.render_svg(svg)
    end

    test "rejects remote svg references before calling the renderer" do
      svg = """
      <svg xmlns="http://www.w3.org/2000/svg" width="12" height="8">
        <image href="https://example.com/image.png" width="12" height="8" />
      </svg>
      """

      assert {:error, :invalid_options} = Media.render_svg(svg)
    end

    test "returns a timeout error when rendering exceeds the caller timeout" do
      Application.put_env(:dian, :media_renderer, SlowRenderer)

      svg = """
      <svg xmlns="http://www.w3.org/2000/svg" width="1" height="1">
        <rect width="1" height="1" fill="#000000" />
      </svg>
      """

      assert {:error, :render_timeout} = Media.render_svg(svg, timeout: 1)
    end

    test "normalizes renderer image-too-large errors" do
      Application.put_env(:dian, :media_renderer, ErrorRenderer)

      svg = """
      <svg xmlns="http://www.w3.org/2000/svg" width="1" height="1">
        <rect width="1" height="1" fill="#000000" />
      </svg>
      """

      assert {:error, :image_too_large} = Media.render_svg(svg)
    end

    test "returns invalid_svg for malformed markup" do
      assert {:error, :invalid_svg} = Media.render_svg("<svg")
    end

    test "rejects unknown options" do
      svg = """
      <svg xmlns="http://www.w3.org/2000/svg" width="1" height="1">
        <rect width="1" height="1" fill="#000000" />
      </svg>
      """

      assert {:error, :invalid_options} = Media.render_svg(svg, dpi: 96)
    end

    test "a caller supplied font file changes rendering when system fonts are disabled" do
      Application.put_env(
        :dian,
        Dian.Media,
        Keyword.put(Application.get_env(:dian, Dian.Media, []), :load_system_fonts, false)
      )

      svg = """
      <svg xmlns="http://www.w3.org/2000/svg" width="220" height="72" viewBox="0 0 220 72">
        <rect width="220" height="72" fill="#ffffff" />
        <text
          x="12"
          y="48"
          fill="#111111"
          font-family="Inter Variable"
          font-size="36"
        >MWwil 0123</text>
      </svg>
      """

      assert {:ok, %RenderedImage{bytes: fallback_bytes}} = Media.render_svg(svg)

      assert {:ok, %RenderedImage{bytes: inter_bytes}} =
               Media.render_svg(svg, fonts: [fixture_font_path("InterVariable.ttf")])

      refute inter_bytes == fallback_bytes
    end
  end
end
