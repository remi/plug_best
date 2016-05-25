:warning: This package is not ready yet! :warning:

PlugBest
==========

`PlugBest` parses HTTP “Accept-*“ headers and returns the best match based on a list of values.

Installation
------------

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add plug_best to your list of dependencies in `mix.exs`:

        def deps do
          [{:plug_best, "~> 0.0.1"}]
        end

  2. Ensure plug_best is started before your application:

        def application do
          [applications: [:plug_best]]
        end

Usage
-----

`PlugBest` currently provides a single basic method:

* `best_language/2`

And plans to add support for the following soon:

* `best_charset/2`
* `best_encoding/2`
* `best_media_type/2`

To find out which language is the best one to use among a list of supported languages:

```elixir
conn |> Plug.Conn.get_req_header("accept-language")
# => ["fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4"]

conn |> PlugBest.best_language(["en", "fr"])
# => "fr"
```

If no values in the header is support, `PlugBest` will return the first `nil`. However,
you can use the `_or_first` suffix to make it return the first value in those cases.

```elixir
conn |> Plug.Conn.get_req_header(conn, "accept-language")
# => ["fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4"]

conn |> PlugBest.best_language(["es", "ru"])
# => nil

conn |> PlugBest.best_language_or_first(["es", "ru"])
# => "es"
```

License
-------

`PlugCanonicalHost` is © 2016 [Rémi Prévost](http://exomel.com) and may be
freely distributed under the [MIT license](https://github.com/remiprev/plug_best/blob/master/LICENSE.md). See the
`LICENSE.md` file for more information.
