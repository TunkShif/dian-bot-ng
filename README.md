# Dian

## Prerequisites

Before running project setup, install:

* Elixir and Erlang/OTP compatible with this project
* `bun` for frontend dependency installation and builds
* Rust toolchain (`rustc` and `cargo`) because the media renderer builds a Rustler NIF

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

`mix setup` will also install frontend dependencies and compile the Rust-based media renderer.

## Custom Fonts

`Dian.Media.render_svg/2` accepts a `fonts:` option with a list of font file paths:

```elixir
svg = ~s(<svg xmlns="http://www.w3.org/2000/svg" width="220" height="72"><text x="12" y="48" font-family="Inter Variable" font-size="36">Hello</text></svg>)

{:ok, image} =
  Dian.Media.render_svg(svg,
    fonts: ["/absolute/path/to/InterVariable.ttf"]
  )
```

The renderer loads bundled fallback fonts from `priv/fonts/` automatically, then appends any caller-supplied font files. Font paths must exist on disk; invalid paths are rejected before rendering starts.

For local tests or fixtures, place font files under `test/support/fixtures/fonts/` and reference them with `Path.expand/2` from your test.
