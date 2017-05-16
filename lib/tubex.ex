defmodule Tubex do
  use Application

  @config Application.get_env(:tubex, Tubex)

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

  def endpoint, do: "https://www.googleapis.com/youtube/v3"

  def api_key do
    @config[:api_key] || System.get_env("YOUTUBE_API_KEY")
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
    @config[:persist]
  end
end
