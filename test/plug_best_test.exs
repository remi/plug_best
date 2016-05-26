defmodule PlugBestTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest PlugBest

  test "returns the best language" do
    conn = %Plug.Conn{req_headers: [{"accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4"}]}

    best_language = conn |> PlugBest.best_language(["fr", "en"])
    assert best_language == {"fr-CA", "fr", 1.0}

    best_language = conn |> PlugBest.best_language(["es", "en"])
    assert best_language == {"en", "en", 0.6}
  end

  test "returns nil when there is no best language" do
    conn = %Plug.Conn{req_headers: [{"accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4"}]}

    best_language = conn |> PlugBest.best_language(["de", "ru"])
    assert best_language == nil
  end

  test "returns the first supported language when no one matches" do
    conn = %Plug.Conn{req_headers: [{"accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4"}]}

    best_language = conn |> PlugBest.best_language_or_first(["de", "ru"])
    assert best_language == {"de", "de", 0.0}
  end
end
