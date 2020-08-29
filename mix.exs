defmodule Olm.MixProject do
  use Mix.Project

  def project do
    [
      app: :olm,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      compilers: [:olm_nifs] ++ Mix.compilers(),
      aliases: aliases()
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
      {:jason, "~> 1.2"}
    ]
  end

  defp aliases do
    [fmt: ["format", "cmd clang-format -i c_src/*.[ch]"]]
  end
end

defmodule Mix.Tasks.Compile.OlmNifs do
  def run(_args) do
    {result, _errcode} = System.cmd("make", [], stderr_to_stdout: true)
    IO.binwrite(result)
  end
end
