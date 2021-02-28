defmodule Tubex.Mixfile do
  use Mix.Project

  @description "Elixir wrapper of YouTube Data API v3"

  def project do
    [app: :tubex,
     version: "0.0.9",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env()),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     description: @description,
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :httpoison],
      mod: {Tubex, []},
      extra_applications: [
        :logger_file_backend
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "test/support"]

  defp package do
    [maintainers: ["Santiago Botta"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/sgobotta/tubex"},
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.6", override: true},
      {:bitcask, "~> 2.0"},
      {:bypass, "~> 0.6", only: :test},
      {:ex_doc, "~> 0.8.0", only: :dev},
      {:earmark, ">= 0.0.0", only: :dev},
      {:logger_file_backend, "~> 0.0.11"}
    ]
  end
end
