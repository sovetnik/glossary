defmodule Glossary.MixProject do
  use Mix.Project

  def project do
    [
      app: :glossary,
      version: "0.2.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Glossary",
      description: description(),
      package: package(),
      source_url: "https://github.com/sovetnik/glossary"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    Minimalistic semantic translation system for Elixir apps.

    Glossary is a lightweight and expressive alternative to gettext for modern Elixir applications — especially Phoenix LiveView.
    """
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.38", only: :dev, runtime: false},
      {:yaml_elixir, "~> 2.11"}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/sovetnik/glossary"}
    ]
  end
end
