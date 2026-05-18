defmodule Tubex.ApiKeyTest do
  use ExUnit.Case, async: false

  @env_keys ["YOUTUBE_API_KEY", "YOUTUBE_TEST_API_KEY"]
  @config_key {:tubex, Tubex}

  setup do
    previous = Application.get_env(@config_key)
    on_exit(fn -> restore_config(previous) end)
    restore_config(nil)
    :ok
  end

  test "prefers Application config over environment variable" do
    System.put_env("YOUTUBE_API_KEY", "from-env")
    Application.put_env(@config_key, api_key: "from-config")

    assert Tubex.api_key() == "from-config"
  end

  test "falls back to YOUTUBE_API_KEY when config api_key is unset" do
    System.put_env("YOUTUBE_API_KEY", "from-env")

    assert Tubex.api_key() == "from-env"
  end

  test "reads config at call time, not from a compile-time module attribute" do
    System.put_env("YOUTUBE_API_KEY", "initial-env")
    assert Tubex.api_key() == "initial-env"

    Application.put_env(@config_key, api_key: "updated-config")
    assert Tubex.api_key() == "updated-config"
  end

  defp restore_config(previous) do
    Enum.each(@env_keys, &System.delete_env/1)

    case previous do
      nil -> Application.delete_env(@config_key)
      value -> Application.put_env(@config_key, value)
    end
  end
end
