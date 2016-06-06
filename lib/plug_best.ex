defmodule PlugBest do
  @moduledoc """
  A library that parses HTTP `Accept-*` headers and returns the best match based
  on a list of values.

  ## Examples

  ```elixir
  iex> conn = %Plug.Conn{req_headers: [{"accept-language", "fr-CA,fr;q=0.8,en;q=0.6,en-US;q=0.4"}]}
  iex> conn |> PlugBest.best_language(["en", "fr"])
  {"fr-CA", "fr", 1.0}

  iex> conn = %Plug.Conn{req_headers: [{"accept-language", "es"}]}
  iex> conn |> PlugBest.best_language(["fr", "ru"])
  nil

  iex> conn = %Plug.Conn{req_headers: [{"accept-language", "es"}]}
  iex> conn |> PlugBest.best_language_or_first(["ru", "fr"])
  {"ru", "ru", 0.0}

  ```
  """

  # Types
  @type language :: {String.t, String.t, float}

  # Aliases
  alias Plug.Conn

  @doc """
  Returns the best supported langage based on the connection `Accept-Language`
  HTTP header. Returns `nil` if none is found.
  """
  @spec best_language(%Conn{}, [String.t, ...]) :: language | nil
  def best_language(conn = %Conn{}, supported_languages) do
    # Fetch the raw header content
    conn |> fetch_header_value("accept-language")

    # Convert it to a list
    |> String.split(",")
    |> Enum.map(&parse_header_value_item/1)

    # Only keep languages that we support
    |> Enum.filter(&(filter_header_value_item(&1, supported_languages)))

    # Sort the parsed header with each score
    |> Enum.sort(&sort_header_value_items/2)

    # Return the first (best!) item
    |> List.first
  end

  @doc """
  Returns the best supported langage based on the connection `Accept-Language`
  HTTP header. Returns the first supported language if none is found.
  """
  @spec best_language_or_first(%Conn{}, [String.t, ...]) :: language
  def best_language_or_first(conn = %Conn{}, supported_languages) do
    conn |> best_language(supported_languages) || default_supported_language(supported_languages)
  end

  @spec default_supported_language([String.t, ...]) :: language
  defp default_supported_language(supported_languages) do
    [default_language | _] = supported_languages
    {default_language, default_language, 0.0}
  end

  @spec fetch_header_value(%Conn{}, String.t) :: String.t
  defp fetch_header_value(conn, header_name) do
    header_value = conn
    |> Conn.get_req_header(header_name)
    |> List.first

    header_value || ""
  end

  @spec parse_header_value_item(String.t) :: language
  defp parse_header_value_item(item) do
    [language, score] = case String.split(item, ";") do
       [language] -> [language, 1.0]
       [language, "q=" <> score] -> [language, String.to_float(score)]
    end

    # Extract base language by removing its suffix
    base_language = language |> String.replace(~r/-.+$/, "")

    {language, base_language, score}
  end

  @spec sort_header_value_items(language, language) :: boolean
  defp sort_header_value_items({_, _, first_score}, {_, _, second_score}) do
    first_score > second_score
  end

  @spec filter_header_value_item(language, [String.t, ...]) :: boolean
  defp filter_header_value_item({_, base_language, _}, supported_languages) do
    Enum.member?(supported_languages, base_language)
  end
end
