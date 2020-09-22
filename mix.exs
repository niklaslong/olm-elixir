defmodule Olm.MixProject do
  use Mix.Project

  def project do
    [
      app: :olm,
      version: "0.1.0-rc",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:olm_nifs] ++ Mix.compilers(),
      aliases: aliases(),
      description: description(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [fmt: ["format", "cmd clang-format -i c_src/*.[ch]"]]
  end

  defp description() do
    """
    Elixir/Erlang NIF bindings for the olm and megolm cryptographic ratchets
    """
  end

  defp docs do
    [
      main: "readme",
      name: "Olm",
      source_url: "https://github.com/niklaslong/olm-elixir",
      extras: ["README.md"]
    ]
  end

  defp package() do
    [
      maintainers: ["Niklas Long"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/niklaslong/olm-elixir"},
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE* c_src Makefile .clang-format)
    ]
  end
end

defmodule Mix.Tasks.Compile.OlmNifs do
  def run(_args) do
    {result, _errcode} = System.cmd("make", [], stderr_to_stdout: true)
    IO.binwrite(result)
  end

  def clean do
    if File.exists?("priv/olm_nif.so") do
      File.rm!("priv/olm_nif.so")
    end
  end
end
