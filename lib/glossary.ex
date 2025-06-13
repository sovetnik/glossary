defmodule Glossary do
  @external_resource Path.join(__DIR__, "glossary.md")
  @moduledoc File.read!(Path.join(__DIR__, "glossary.md"))

  @doc """
  Injects the `t/2` function into the caller module for lexeme localization.

  `sources` is a list of relative paths (without extensions or locale suffixes) to YAML files
  containing lexeme–expression mappings.

  Example:

      use Glossary, ["../common", "project"]
  """

  defmacro __using__(sources) do
    expressions =
      __CALLER__.file
      |> Path.dirname()
      |> Glossary.Lexicon.compile(sources, __CALLER__.module)

    require Logger

    Logger.debug(
      "[Glossary] built for #{__CALLER__.module} #{inspect(expressions, pretty: true)}"
    )

    quote do
      require Logger
      @glossary unquote(Macro.escape(expressions))

      @doc """
      Returns the expression of a lexeme in the given locale.

      Falls back to returning the `lexeme` itself if no expression is found,
      and logs a warning with the full key.

      ## Example

          t("motto.glossary", "la")
          #=> "Clavis interpretandi"

          t("motto.glossary", "en")
          #=> "The key to understanding"

      """
      def t(lexeme, locale) when is_binary(lexeme) and is_binary(locale) do
        lexeme
        |> Glossary.Lexeme.qualify(locale)
        |> Glossary.Lexeme.lookup(@glossary, [])
      end

      @doc """
      Returns the expression of a lexeme in the given locale with interpolated bindings.

      Placeholders in the form `{{key}}` (without spaces) are replaced by corresponding values.
      Falls back to returning the `lexeme` itself if no expression is found.

      ## Examples

          t("game.score", "en", score: 42)
          #=> "Score: 42"

          t("greeting", "en", name: "Alice")
          #=> "Hello, Alice!"
      """
      @spec t(String.t(), String.t(), keyword()) :: String.t()
      def t(lexeme, locale, bindings)
          when is_binary(lexeme) and is_binary(locale) and is_list(bindings) do
        lexeme
        |> Glossary.Lexeme.qualify(locale)
        |> Glossary.Lexeme.lookup(@glossary, bindings)
      end
    end
  end
end
