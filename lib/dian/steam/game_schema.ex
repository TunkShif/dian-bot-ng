defmodule Dian.Steam.GameSchema do
  alias Dian.Steam
  alias Dian.Steam.GameSchema.Achievement

  @cache_name :dian_cache
  @cache_ttl :timer.hours(24)

  defstruct [
    :app_id,
    :game_name,
    :game_version,
    achievements: %{}
  ]

  @type t :: %__MODULE__{
          app_id: String.t() | nil,
          game_name: String.t() | nil,
          game_version: String.t() | nil,
          achievements: %{optional(String.t()) => Achievement.t()}
        }

  defmodule Achievement do
    defstruct [
      :api_name,
      :display_name,
      :description,
      :hidden,
      :icon_url,
      :icon_gray_url
    ]

    @type t :: %__MODULE__{
            api_name: String.t() | nil,
            display_name: String.t() | nil,
            description: String.t() | nil,
            hidden: boolean() | nil,
            icon_url: String.t() | nil,
            icon_gray_url: String.t() | nil
          }

    def build(params) do
      %__MODULE__{
        api_name: params["name"],
        display_name: params["displayName"],
        description: params["description"],
        hidden: params["hidden"] == 1,
        icon_url: params["icon"],
        icon_gray_url: params["icongray"]
      }
    end
  end

  def build(app_id, params) do
    achievements =
      get_in(params, ["availableGameStats", "achievements"]) || []

    %__MODULE__{
      app_id: app_id,
      game_name: params["gameName"],
      game_version: params["gameVersion"],
      achievements:
        Map.new(achievements, fn achievement ->
          built = Achievement.build(achievement)
          {built.api_name, built}
        end)
    }
  end

  def fetch(app_id, locale \\ :zh, opts \\ [])
      when is_binary(app_id) and is_atom(locale) and is_list(opts) do
    cache_name = Keyword.get(opts, :cache_name, @cache_name)
    get_game_schema = Keyword.get(opts, :get_game_schema, &Steam.get_game_schema/2)
    cache_key = {:steam_game_schema, app_id, locale}

    case Cachex.get(cache_name, cache_key) do
      {:ok, nil} ->
        with {:ok, %__MODULE__{} = schema} <- get_game_schema.(app_id, locale) do
          _ = Cachex.put(cache_name, cache_key, schema, ttl: @cache_ttl)
          {:ok, schema}
        end

      {:ok, %__MODULE__{} = schema} ->
        {:ok, schema}

      {:ok, other} when is_map(other) ->
        {:ok, struct(__MODULE__, other)}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
