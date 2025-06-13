defmodule Glossary.LexemeTest do
  use ExUnit.Case, async: true
  import Glossary.Lexeme

  describe "identify/1" do
    test "returns full lexeme with validation, kind, and type" do
      assert "validation.length.min.string" ==
               identify(%{validation: :length, kind: :min, type: :string})
    end

    test "returns lexeme with validation and kind only" do
      assert "validation.length.min" ==
               identify(%{validation: :length, kind: :min})
    end

    test "returns lexeme with validation only" do
      assert "validation.required" ==
               identify(%{validation: :required})
    end

    test "logs and returns fallback when validation is missing" do
      assert "validation.unknown" ==
               identify(%{kind: :min})
    end
  end

  describe "qualify/2" do
    test "concatenates locale and lexeme" do
      assert "en.validation.required" ==
               qualify("validation.required", "en")

      assert "ru.validation.length.min" ==
               qualify("validation.length.min", "ru")
    end
  end

  describe "lookup/4" do
    setup do
      glossary = %{
        "en.validation.required" => "can't be blank",
        "ru.validation.required" => "не может быть пустым",
        "en.validation.term_state" => "Term {{body}} is not NEW but {{state}} instead"
      }

      [glossary: glossary]
    end

    test "returns interpolated value when key is present", %{glossary: glossary} do
      assert "Term T1 is not NEW but CLOSED instead" ==
               lookup("en.validation.term_state", glossary, [body: "T1", state: "CLOSED"], nil)
    end

    test "returns raw string if no bindings match", %{glossary: glossary} do
      assert "Term {{body}} is not NEW but {{state}} instead" ==
               lookup("en.validation.term_state", glossary, [], nil)
    end

    test "returns fallback if key is missing", %{glossary: glossary} do
      assert "default" ==
               lookup("en.validation.unknown", glossary, [], "default")
    end

    test "returns key if missing and no fallback", %{glossary: glossary} do
      assert "en.validation.unknown" ==
               lookup("en.validation.unknown", glossary, [], nil)
    end
  end
end
