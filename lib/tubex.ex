defmodule Tubex do
  use Application

  def start(_type, _args) do
    persistence_set_defaults()
    import Supervisor.Spec, warn: false

    children = [
      # worker(:bitcask_merge_worker, []),
      # worker(:bitcask_merge_delete, [])
    ]
    opts = [strategy: :one_for_one, name: ExBitcask.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def endpoint do
    case System.get_env("MIX_ENV") do
      "test" -> "https://test.ex"
      _      -> "https://www.googleapis.com/youtube/v3"
    end
  end

  @doc """
  Returns the YouTube Data API key.

  Resolution order (first non-nil wins):

  1. `Application.get_env(:tubex, Tubex)[:api_key]` (set in config or `runtime.exs`)
  2. `YOUTUBE_TEST_API_KEY` when `MIX_ENV=test`, otherwise `YOUTUBE_API_KEY`

  Config is read at call time so host apps can change `.env` and restart without
  recompiling the tubex dependency.
  """
  def api_key do
    config()[:api_key] || env_api_key()
  end

  defp env_api_key do
    case System.get_env("MIX_ENV") do
      "test" -> System.get_env("YOUTUBE_TEST_API_KEY")
      _ -> System.get_env("YOUTUBE_API_KEY")
    end
  end

  defp config do
    Application.get_env(:tubex, Tubex, [])
  end

  def api_client do
    case System.get_env("MIX_ENV") do
      "test" -> Tubex.MockAPI
      _      -> Tubex.API
    end
  end

  @moduledoc false
  def persistence_set_defaults() do
    defaults = [
      {:max_file_size, 2147483648},
      {:tombstone_version, 2},
      {:open_timeout, 4},
      {:sync_strategy, :none},
      {:require_hint_crc, false},
      {:merge_window, :always},
      {:frag_merge_trigger, 60},
      {:dead_bytes_merge_trigger, 536870912},
      {:frag_threshold, 40},
      {:dead_bytes_threshold, 134217728},
      {:small_file_threshold, 10485760},
      {:max_fold_age, -1},
      {:max_fold_puts, 0},
      {:expiry_secs, -1}
    ]
    for {key, val} <- defaults do
      if Application.get_env(:bitcask, key) == nil do
        Application.put_env(:bitcask, key, val)
      end
    end
  end

  def persistence_config do
    config()[:persist]
  end
end
