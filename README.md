# Olm

Elixir wrapper for [Olm](https://gitlab.matrix.org/matrix-org/olm).

## Installation

### Install Olm

Olm is a native C library. The library is packaged by several distributions.

On Debian one can install it like so:

    apt install libolm-dev

On Darwin: 

    brew install libolm

NOTE: one must set the `ERL_ROOT` environment var, usually `/usr/local/lib/erlang/erts-version`

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `olm` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:olm, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/olm](https://hexdocs.pm/olm).
