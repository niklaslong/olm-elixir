# Olm

Elixir wrapper for [Olm](https://gitlab.matrix.org/matrix-org/olm).

## Installation

Olm is a native C library. The library is packaged by several distributions.

On Debian one can install it like so:

    apt install libolm-dev

On Darwin: 

    brew install libolm

NOTE: one must set the `ERL_ROOT` environment var, usually `/usr/local/lib/erlang/erts-version`

Once this is done, the package can be installed by adding `olm` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:olm, "~> 0.1.0-rc"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/olm](https://hexdocs.pm/olm).
