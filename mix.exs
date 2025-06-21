defmodule GenFST.Mixfile do
  use Mix.Project

  @version "0.5.0"
  @source_url "https://github.com/xiamx/gen_fst"

  def project do
    [
      app: :gen_fst,
      version: @version,
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      source_url: @source_url,
      homepage_url: @source_url,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        "test.watch": :test
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:gen_state_machine, "~> 3.0"},
      {:libgraph, "~> 0.16"},

      # Development dependencies
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    GenFST implements a generic finite state transducer with customizable rules 
    elegantly expressed in a DSL. Perfect for morphological parsing, text 
    transformation, and linguistic analysis tasks.
    """
  end

  defp package do
    # These are the default files included in the package
    [
      name: :gen_fst,
      files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"],
      maintainers: ["Meng Xuan Xia"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/gen_fst"
      }
    ]
  end

  defp docs do
    [
      main: "GenFST",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_functions: [
        "Core Functions": [
          :new,
          :rule,
          :parse
        ],
        "Batch Operations": [
          :parse_batch,
          :can_parse?
        ],
        Utilities: [
          :stats
        ]
      ]
    ]
  end

  defp aliases do
    [
      "test.watch": ["test.watch --stale"],
      quality: ["format", "credo --strict", "dialyzer"],
      "quality.ci": [
        "format --check-formatted",
        "credo --strict",
        "dialyzer"
      ]
    ]
  end
end
