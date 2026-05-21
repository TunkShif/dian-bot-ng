# Dian

[English](README.md) | **简体中文**

## 前置依赖

在运行项目设置之前，请安装：

- 与本项目兼容的 Elixir 和 Erlang/OTP
- `bun`，用于前端依赖安装和构建
- Rust 工具链（`rustc` 和 `cargo`），因为媒体渲染器使用 Rustler NIF

启动 Phoenix 服务器：

- 运行 `mix setup` 安装并配置依赖
- 使用 `mix phx.server` 或在 IEx 中使用 `iex -S mix phx.server` 启动 Phoenix 端点

`mix setup` 也会安装前端依赖并编译基于 Rust 的 SVG 渲染器。

## 自定义字体

`Dian.Media.render_svg/2` 接受 `fonts:` 选项，参数为字体文件路径列表：

```elixir
svg = ~s(<svg xmlns="http://www.w3.org/2000/svg" width="220" height="72"><text x="12" y="48" font-family="Inter Variable" font-size="36">Hello</text></svg>)

{:ok, image} =
  Dian.Media.render_svg(svg,
    fonts: ["/absolute/path/to/InterVariable.ttf"]
  )
```

渲染器会自动加载 `priv/fonts/` 中捆绑的后备字体，然后附加调用者提供的字体文件。字体路径必须存在于磁盘上；无效路径会在渲染开始前被拒绝。

对于本地测试或测试夹具，将字体文件放在 `test/support/fixtures/fonts/` 下，并使用 `Path.expand/2` 引用它们。

`priv/fonts/` 已包含用于 Steam 状态卡片模板的 `WenQuanYi Micro Hei` 字体。当渲染的 SVG 需要中文文本时，将其作为首选字体族，并在卡片需要不同字型时在其旁添加额外的字体文件。

## 部署

本项目使用多阶段 Docker 构建生产版本。推荐方法遵循 [Phoenix 容器部署指南](https://hexdocs.pm/phoenix/releases.html#containers)。

### 构建镜像

```sh
docker build -t dian .
```

### 必需的环境变量

以下变量在运行时通过 `config/runtime.exs` 读取。密钥不应内置于镜像中——应在创建容器时提供。

| 变量 | 必需 | 默认值 | 说明 |
|---|---|---|---|
| `SECRET_KEY_BASE` | 是 | — | 用于签名/加密 Cookie 和密钥。使用 `mix phx.gen.secret` 生成 |
| `DATABASE_PATH` | 是 | — | SQLite 数据库文件路径（例如 `/etc/dian/dian.db`） |
| `WEBAUTHN_ORIGIN` | 是 | — | 前端/API 的完整 URL，包含 `https://`，无尾部斜杠 |
| `WEBAUTHN_RP_ID` | 是 | — | WebAuthn 依赖方域名（无 scheme，无端口） |
| `PHX_HOST` | 否 | `example.com` | Phoenix 端点的主机域名 |
| `PORT` | 否 | `4000` | HTTP 监听端口 |
| `PHX_SERVER` | 否 | — | 设置为 `true` 以在 release 中启动服务器 |
| `POOL_SIZE` | 否 | `5` | Ecto 数据库连接池大小 |
| `DNS_CLUSTER_QUERY` | 否 | — | 用于[集群](https://hexdocs.pm/phoenix/telemetry.html#distribution)的 DNS 查询 |
| `BOT_ENDPOINT` | 否 | — | Bot Webhook 端点 URL |
| `BOT_ACCESS_TOKEN` | 否 | — | Bot Webhook 访问令牌 |
| `STEAM_API_KEY` | 否 | — | [Steam Web API 密钥](https://steamcommunity.com/dev/apikey) |
| `DEEPSEEK_API_KEY` | 否 | — | DeepSeek API 密钥，用于 AI 驱动的摘要 |
| `DEEPSEEK_MODEL` | 否 | `deepseek-v4-flash` | 用于 AI 功能的 DeepSeek 模型 ID |
| `ENABLE_AI_DAILY_SUMMARY` | 否 | `false` | 设置为 `true` 以启用 AI 生成的每日摘要 |
| `RESEND_API_KEY` | 否 | — | [Resend](https://resend.com) API 密钥，用于事务性邮件 |
| `USER_NOTIFIER_EMAIL_SENDER` | 否 | `contact@example.com` | 用户通知的发件人邮箱地址 |

### 运行容器

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

挂载持久化卷以存储 SQLite 数据库文件，确保容器重启后数据不丢失。
