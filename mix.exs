defmodule PlugBest.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [app: :plug_best,
     version: @version,
     elixir: "~> 1.2",
     deps: deps,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: "https://github.com/remiprev/plug_best",
     homepage_url: "https://github.com/remiprev/plug_best",
     description: "A Plug to parse HTTP “Accept-*” headers and return the best match based on a list of values.",
     docs: [extras: ["README.md"], main: "readme", source_ref: "v#{@version}", source_url: "https://github.com/remiprev/plug_best"]]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:plug, " ~> 1.0"},
      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev}
    ]
  end

  defp package do
    [name: :plug_best,
     maintainers: ["Rémi Prévost"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/remiprev/plug_best"}]
  end
end
