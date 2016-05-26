defmodule PlugBest do
  def best_language(conn = %Plug.Conn{}, supported_languages) do
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

  def best_language_or_first(conn = %Plug.Conn{}, supported_languages) do
    conn |> best_language(supported_languages) || default_supported_language(supported_languages)
  end

  defp default_supported_language(supported_languages) do
    [default_language | _] = supported_languages
    {default_language, default_language, 0.0}
  end

  defp fetch_header_value(conn, header_name) do
    conn
    |> Plug.Conn.get_req_header(header_name)
    |> List.first
  end

  defp parse_header_value_item(item) do
    [language, score] = case String.split(item, ";") do
       [language] -> [language, "q=1.0"]
       [language, score] -> [language, score]
    end

    # Extract base language by removing its suffix
    base_language = language |> String.replace(~r/-.+$/, "")

    {language, base_language, parsed_score(score)}
  end

  defp parsed_score("q=" <> score), do: String.to_float(score)

  defp sort_header_value_items({_, _, first_score}, {_, _, second_score}) do
    first_score > second_score
  end

  defp filter_header_value_item({_, base_language, _}, supported_languages) do
    Enum.member?(supported_languages, base_language)
  end
end
