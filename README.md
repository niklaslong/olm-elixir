# Olm

Elixir wrapper for [Olm](https://gitlab.matrix.org/matrix-org/olm), an
implementation of the Double Ratchet cryptographic ratchet.

## Installation

Olm is a native C library. The library is packaged by several distributions.

On Debian one can install it like so:

    apt install libolm-dev

On Darwin:

    brew install libolm

If you're on Apple Silicon you may also need to (see https://github.com/niklaslong/olm-elixir/issues/35):

```
export CPATH=/opt/homebrew/include
export LIBRARY_PATH=/opt/homebrew/lib
```

The package can be installed by adding `olm` to your list of dependencies in
`mix.exs`:

```elixir
def deps do
  [
    {:olm, "~> 0.1.0-rc"}
  ]
end
```

The docs can be found at [https://hexdocs.pm/olm](https://hexdocs.pm/olm).
