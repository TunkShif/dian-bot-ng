# Find eligible builder and runner images on Docker Hub. Phoenix recommends
# Ubuntu/Debian images instead of Alpine to avoid DNS resolution issues.
#
# https://hexdocs.pm/phoenix/releases.html#containers
# https://hub.docker.com/r/hexpm/elixir/tags
# https://hub.docker.com/_/debian/tags
#
ARG ELIXIR_VERSION=1.19.5
ARG OTP_VERSION=28.4
ARG RUST_VERSION=1.95.0
ARG DEBIAN_VERSION=trixie-20260518-slim
ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS builder

ARG RUST_VERSION

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    unzip \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --profile minimal --default-toolchain ${RUST_VERSION}

ENV PATH="/root/.cargo/bin:${PATH}"

RUN mix local.hex --force \
  && mix local.rebar --force

ENV MIX_ENV="prod"

COPY mix.exs mix.lock ./
RUN mix deps.get --only $MIX_ENV
RUN mkdir config

COPY config/config.exs config/${MIX_ENV}.exs config/
RUN mix deps.compile

COPY assets/package.json assets/bun.lock assets/
RUN mix assets.setup

COPY priv priv
COPY lib lib
COPY native native
RUN mix compile

COPY assets assets
COPY openapi.json .
RUN mix assets.deploy

COPY config/runtime.exs config/
COPY rel rel
RUN mix release

FROM ${RUNNER_IMAGE} AS final

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    libncurses6 \
    libsqlite3-0 \
    libstdc++6 \
    locales \
    openssl \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV MIX_ENV="prod"

WORKDIR /app
RUN chown nobody /app

COPY --from=builder --chown=nobody:root /app/_build/${MIX_ENV}/rel/dian ./

USER nobody

CMD ["/app/bin/server"]
