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

  # Aliases
  alias Plug.Conn

  # Types
  @type value :: {String.t(), String.t(), float}

  @doc """
  Returns the best supported langage based on the connection `Accept-Language`
  HTTP header. Returns `nil` if none is found.
  """
  @spec best_language(%Conn{}, [String.t()]) :: value | nil
  def best_language(conn = %Conn{}, supported_values), do: best_value(conn, "accept-language", supported_values)

  @doc """
  Returns the best supported langage based on the connection `Accept-Language`
  HTTP header. Returns the first supported language if none is found.
  """
  @spec best_language_or_first(%Conn{}, [String.t()]) :: value | nil
  def best_language_or_first(conn = %Conn{}, supported_values), do: best_value_or_first(conn, "accept-language", supported_values)

  @doc """
  Returns the best supported charset based on the connection `Accept-Charset`
  HTTP header. Returns `nil` if none is found.
  """
  @spec best_charset(%Conn{}, [String.t()]) :: value | nil
  def best_charset(conn = %Conn{}, supported_values), do: best_value(conn, "accept-charset", supported_values)

  @doc """
  Returns the best supported charset based on the connection `Accept-Charset`
  HTTP header. Returns the first supported charset if none is found.
  """
  @spec best_charset_or_first(%Conn{}, [String.t()]) :: value | nil
  def best_charset_or_first(conn = %Conn{}, supported_values), do: best_value_or_first(conn, "accept-charset", supported_values)

  @doc """
  Returns the best supported encoding based on the connection `Accept-Encoding`
  HTTP header. Returns `nil` if none is found.
  """
  @spec best_encoding(%Conn{}, [String.t()]) :: value | nil
  def best_encoding(conn = %Conn{}, supported_values), do: best_value(conn, "accept-encoding", supported_values)

  @doc """
  Returns the best supported encoding based on the connection `Accept-Encoding`
  HTTP header. Returns the first supported encoding if none is found.
  """
  @spec best_encoding_or_first(%Conn{}, [String.t()]) :: value | nil
  def best_encoding_or_first(conn = %Conn{}, supported_values), do: best_value_or_first(conn, "accept-encoding", supported_values)

  @doc """
  Returns the best supported type based on the connection `Accept`
  HTTP header. Returns `nil` if none is found.
  """
  @spec best_type(%Conn{}, [String.t()]) :: value | nil
  def best_type(conn = %Conn{}, supported_values), do: best_value(conn, "accept", supported_values)

  @doc """
  Returns the best supported type based on the connection `Accept`
  HTTP header. Returns the first supported type if none is found.
  """
  @spec best_type_or_first(%Conn{}, [String.t()]) :: value | nil
  def best_type_or_first(conn = %Conn{}, supported_values), do: best_value_or_first(conn, "accept", supported_values)

  @spec best_value(%Conn{}, String.t(), [String.t()]) :: value | nil
  defp best_value(conn = %Conn{}, header, supported_values) do
    # Fetch the raw header content
    conn
    |> fetch_header_value(header)

    # Convert it to a list
    |> String.split(",")
    |> Enum.map(&parse_header_item/1)

    # Only keep values that we support
    |> Enum.filter(&filter_header_value_item(&1, supported_values))

    # Sort the parsed header with each score
    |> Enum.sort(&sort_header_value_items/2)

    # Return the first (best!) item
    |> List.first()
  end

  @spec best_value_or_first(%Conn{}, String.t(), [String.t()]) :: value
  defp best_value_or_first(conn = %Conn{}, header, supported_values) do
    conn |> best_value(header, supported_values) || default_supported_value(supported_values)
  end

  @spec default_supported_value([String.t()]) :: value
  defp default_supported_value(supported_values) do
    [default_value | _] = supported_values
    {default_value, default_value, 0.0}
  end

  @spec fetch_header_value(%Conn{}, String.t()) :: String.t()
  defp fetch_header_value(conn, header_name) do
    header_value =
      conn
      |> Conn.get_req_header(header_name)
      |> List.first()

    header_value || ""
  end

  @spec parse_header_item(String.t()) :: value
  defp parse_header_item(item) do
    [value, score] =
      case String.split(item, ";") do
        [value] -> [value, 1.0]
        [value, "q=" <> score] -> [value, parse_score(score)]
      end

    # Extract base value by removing its suffix
    base_value = value |> String.replace(~r/-.+$/, "")

    {value, base_value, score}
  end

  @spec sort_header_value_items(value, value) :: boolean
  defp sort_header_value_items({_, _, first_score}, {_, _, second_score}) do
    first_score > second_score
  end

  @spec filter_header_value_item(value, [String.t()]) :: boolean
  defp filter_header_value_item({_, base_value, _}, supported_values) do
    Enum.member?(supported_values, base_value)
  end

  @spec parse_score(String.t()) :: float
  defp parse_score(score) do
    case Float.parse(score) do
      {score, _} -> score
      :error -> 0.0
    end
  end
end
