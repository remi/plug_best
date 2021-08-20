# PlugBest

<a href="https://github.com/remi/plug_best/actions?query=workflow%3ACI+branch%3Amaster+event%3Apush"><img src="https://github.com/remi/plug_best/workflows/CI/badge.svg?branch=master&event=push" /></a>
<a href="https://hex.pm/packages/plug_best"><img src="https://img.shields.io/hexpm/v/plug_best.svg" /></a>

`PlugBest` parses HTTP `Accept-*` headers and returns the best match based on a list of values.

## Installation

Add `plug_best` to the `deps` function in your project's `mix.exs` file:

```elixir
defp deps do
  [
    …,
    {:plug_best, "~> 0.3"}
  ]
end
```

Then run `mix do deps.get, deps.compile` inside your project's directory.

## Usage

`PlugBest` currently provides eight methods:

- `best_language/2`
- `best_language_or_first/2`
- `best_charset/2`
- `best_charset_or_first/2`
- `best_encoding/2`
- `best_encoding_or_first/2`
- `best_type/2`
- `best_type_or_first/2`

To find out which language is the best one to use among a list of supported languages:

```elixir
conn |> Plug.Conn.get_req_header("accept-language")
# => ["fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4"]

conn |> PlugBest.best_language(["en", "fr"])
# => {"fr-CA", "fr", 1.0}
```

If no values in the header is support, `PlugBest` will return the first `nil`. However,
you can use the `_or_first` suffix to make it return the first value in those cases.

```elixir
conn |> Plug.Conn.get_req_header("accept-language")
# => ["fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4"]

conn |> PlugBest.best_language(["es", "ru"])
# => nil

conn |> PlugBest.best_language_or_first(["es", "ru"])
# => {"es", "es", 0.0}
```

## License

`PlugBest` is © 2016-2017 [Rémi Prévost](http://exomel.com) and may be
freely distributed under the [MIT license](https://github.com/remiprev/plug_best/blob/master/LICENSE.md). See the
`LICENSE.md` file for more information.
