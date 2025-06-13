defmodule Glossary.Ecto do
  @moduledoc """
  Provides the `hint/2` function for translating custom Ecto validation messages
  using a localized glossary.

  Designed for use in modules that define or consume `Ecto.Changeset` validations.

  ## Why?

  Ecto allows adding errors with custom messages and metadata:

      add_error(
        changeset,
        :field,
        "you're doing it wrong",
        foo: "bar",
        validation: :foobar
      )

  Later, you can retrieve that message from the changeset:

      {"you're doing it wrong", [foo: "bar", validation: :foobar]}

  `Glossary.Ecto.hint/2` takes this `{message, opts}` tuple along with a `locale`
  and returns a localized, interpolated string — or falls back to the original.

  ## Usage

      defmodule MyApp.Validation do
        use Glossary.Ecto, ["../locales/validation"]
      end

      MyApp.Validation.hint({"you're doing it wrong", [foo: "bar", validation: :foobar]}, "en")
      #=> "you're doing bar wrong"

  ## Source format

  The glossary is built from YAML files like this:

      # validation.en.yml
      validation:
        foobar: "you're doing {{foo}} wrong"

      # validation.ru.yml
      validation:
        foobar: "вы неправильно делаете {{foo}}"

  File paths passed to `use Glossary.Ecto` should be base paths without extension or locale suffix.
  """
  defmacro __using__(sources) do
    expressions =
      __CALLER__.file
      |> Path.dirname()
      |> Glossary.Lexicon.compile(sources, __CALLER__.module)

    quote do
      @glossary unquote(Macro.escape(expressions))

      @doc """
      Looks up a localized message for a given `{message, opts}` tuple and `locale`.

      This is intended for use with `Ecto.Changeset` validation errors.

      The `opts` must include at least `:validation` (used to identify the lexeme),
      and may include `:kind`, `:type`, or any number of interpolation keys.

      If no match is found, returns the original `message`.

      ## Examples

          hint({"you're doing it wrong", [foo: "bar", validation: :foobar]}, "en")
          #=> "you're doing bar wrong"

          hint({"you're doing it wrong", [foo: "bar", validation: :foobar]}, "ru")
          #=> "вы неправильно делаете bar"

      """
      @spec hint({String.t(), keyword()}, String.t()) :: String.t()
      def hint({message, opts}, locale) do
        Glossary.Lexeme.identify(Map.new(opts))
        |> Glossary.Lexeme.qualify(locale)
        |> Glossary.Lexeme.lookup(@glossary, opts, message)
      end
    end
  end
end
