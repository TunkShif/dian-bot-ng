<div align="center">

# Dian

**A modern QQ bot platform powered by Phoenix and React**

[![Version](https://img.shields.io/badge/version-1.0.0-blue)](https://github.com/your-username/dian-bot-ng)
[![License](https://img.shields.io/badge/license-AGPL--3.0-green)](LICENSE)
[![Elixir](https://img.shields.io/badge/elixir-~>1.15-purple)](https://elixir-lang.org)
[![Phoenix](https://img.shields.io/badge/phoenix-~>1.8-orange)](https://phoenixframework.org)

**English** | [简体中文](README_zh-CN.md)

</div>

## ✨ Features

- **OneBot Protocol Support** - Seamless integration with QQ bots via WebSocket
- **Steam Integration** - Track player status, achievements, and play sessions
- **AI-Powered Summaries** - Daily summaries using DeepSeek AI
- **WebAuthn Authentication** - Secure passwordless login
- **Real-time Updates** - Live data streaming via Phoenix PubSub
- **Media Rendering** - SVG-to-image conversion with custom fonts (Rust NIF)
- **Multi-language Support** - i18n with English and Chinese locales

## 🚀 Tech Stack

### Backend
- **Elixir** ~1.15 with **Phoenix** ~1.8.5
- **SQLite** via Ecto + ecto_sqlite3
- **WebSockex** for OneBot protocol communication
- **Req** for HTTP requests (Steam API, DeepSeek)
- **Rustler** NIF for media rendering

### Frontend
- **React** 19 with **React Router** v6
- **shadcn/ui** components
- **TanStack Query** for data fetching
- **TanStack Form** for form management
- **i18next** for internationalization
- **nuqs** for URL state management

## 📋 Prerequisites

Before running project setup, install:

- [Elixir](https://elixir-lang.org/install.html) and Erlang/OTP compatible with this project
- [bun](https://bun.sh) for frontend dependency installation and builds
- [Rust](https://rustup.rs) toolchain (`rustc` and `cargo`) because the media renderer builds a Rustler NIF

## 🛠️ Development Setup

1. **Clone the repository**
   ```sh
   git clone https://github.com/your-username/dian-bot-ng.git
   cd dian-bot-ng
   ```

2. **Install dependencies and setup**
   ```sh
   mix setup
   ```
   This will:
   - Install Elixir dependencies
   - Install frontend dependencies via `bun`
   - Compile the Rust-based media renderer
   - Setup the database

3. **Start the development server**
   ```sh
   mix phx.server
   ```
   Or with interactive shell:
   ```sh
   iex -S mix phx.server
   ```

4. **Visit the application**
   Open [http://localhost:4000](http://localhost:4000) in your browser.

## 🎨 Custom Fonts

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

`priv/fonts/` already includes `WenQuanYi Micro Hei` for the Steam status card templates. Use it as the first family when you need Chinese text in rendered SVGs, and add extra font files alongside it when a card needs a different typeface.

## 🐳 Deployment

This project uses a multi-stage Docker build for production releases. The recommended approach follows the [Phoenix container deployment guide](https://hexdocs.pm/phoenix/releases.html#containers).

### Building the image

```sh
docker build -t dian .
```

### Required environment variables

These are read at runtime via `config/runtime.exs`. Secrets should not be baked into the image — provide them when creating containers.

| Variable | Required | Default | Description |
|---|---|---|---|
| `SECRET_KEY_BASE` | Yes | — | Used to sign/encrypt cookies and secrets. Generate with `mix phx.gen.secret` |
| `DATABASE_PATH` | Yes | — | Path to the SQLite database file (e.g. `/etc/dian/dian.db`) |
| `WEBAUTHN_ORIGIN` | Yes | — | Full URL of the frontend/API including `https://`, no trailing slash |
| `WEBAUTHN_RP_ID` | Yes | — | WebAuthn relying party domain (no scheme, no port) |
| `PHX_HOST` | No | `example.com` | Host domain for the Phoenix endpoint |
| `PORT` | No | `4000` | HTTP listener port |
| `PHX_SERVER` | No | — | Set to `true` to start the server in a release |
| `POOL_SIZE` | No | `5` | Ecto database connection pool size |
| `DNS_CLUSTER_QUERY` | No | — | DNS query for [clustering](https://hexdocs.pm/phoenix/telemetry.html#distribution) |
| `BOT_ENDPOINT` | No | — | Bot webhook endpoint URL |
| `BOT_ACCESS_TOKEN` | No | — | Bot webhook access token |
| `STEAM_API_KEY` | No | — | [Steam Web API key](https://steamcommunity.com/dev/apikey) |
| `DEEPSEEK_API_KEY` | No | — | DeepSeek API key for AI-powered summaries |
| `DEEPSEEK_MODEL` | No | `deepseek-v4-flash` | DeepSeek model ID to use for AI features |
| `ENABLE_AI_DAILY_SUMMARY` | No | `false` | Set to `true` to enable AI-generated daily summaries |
| `RESEND_API_KEY` | No | — | [Resend](https://resend.com) API key for transactional emails |
| `USER_NOTIFIER_EMAIL_SENDER` | No | `contact@example.com` | Sender email address for user notifications |

### Running the container

```sh
docker run -d \
  --name dian \
  -p 4000:4000 \
  -v /path/to/data:/etc/dian \
  -e SECRET_KEY_BASE=... \
  -e DATABASE_PATH=/etc/dian/dian.db \
  -e WEBAUTHN_ORIGIN=https://your-domain.com \
  -e WEBAUTHN_RP_ID=your-domain.com \
  -e PHX_HOST=your-domain.com \
  -e PHX_SERVER=true \
  dian
```

Mount a persistent volume for the SQLite database file so it survives container restarts.

## 📄 License

This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).
