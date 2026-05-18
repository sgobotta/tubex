# Tubex

Lightweight YouTube v3 API Wrapper

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add tubex to your list of dependencies in `mix.exs`:

        def deps do
          [{:tubex, "~> 0.0.1"}]
        end

  2. Ensure tubex is started before your application:

        def application do
          [applications: [:tubex]]
        end

  3. Configure your YouTube Data API key (either approach works):

**Environment variable (recommended for local dev):**

```bash
export YOUTUBE_API_KEY=your-api-key-without-quotes
```

**Application config** (e.g. in `config/runtime.exs` for releases):

```elixir
config :tubex, Tubex, api_key: System.get_env("YOUTUBE_API_KEY")
```

`Tubex.api_key/0` reads config at runtime, so changing `.env` only requires
restarting the app—not recompiling tubex. Avoid wrapping the key in quotes in
shell env files when using `make include`; extra `"` characters become part of
the key and Google will reject the request.


## Usage

```elixir
Tubex.Video.search_by_query("Cooking")
```
