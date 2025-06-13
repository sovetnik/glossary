defmodule Glossary.EctoTest do
  use ExUnit.Case, async: true

  defmodule Validation do
    use Glossary.Ecto, ["../../test/support/locales/validation"]
  end

  describe "hint/2 – standard validators" do
    test "required / acceptance" do
      assert "can't be blank" =
               Validation.hint({"can't be blank", validation: :required}, "en")

      assert "не может быть пустым" =
               Validation.hint({"can't be blank", validation: :required}, "ru")

      assert "must be accepted" =
               Validation.hint({"must be accepted", validation: :acceptance}, "en")

      assert "должно быть принято" =
               Validation.hint({"must be accepted", validation: :acceptance}, "ru")
    end
  end

  describe "hint/2 – length validator (deep keys with interpolation)" do
    test ":is / string" do
      msg =
        {"should be %{count} character(s)",
         [validation: :length, kind: :is, type: :string, count: 4]}

      assert "should be 4 character(s)" = Validation.hint(msg, "en")
      assert "должно быть 4 символ(ов)" = Validation.hint(msg, "ru")
    end

    test ":min / map" do
      msg =
        {"should be at least %{count} item(s)",
         [validation: :length, kind: :min, type: :map, count: 2]}

      assert "should have at least 2 item(s)" = Validation.hint(msg, "en")
      assert "должно быть не менее 2 элемент(ов)" = Validation.hint(msg, "ru")
    end
  end

  describe "hint/2 – custom validators with named placeholders" do
    test "term_state" do
      msg =
        {"Term %{body} is not NEW but %{state} instead",
         [
           validation: :term_state,
           body: "T-100",
           state: "CONFIRMED",
           enum: ~w[new confirmed archived]
         ]}

      assert "Term T-100 is not NEW but CONFIRMED instead" = Validation.hint(msg, "en")
      assert "Термин T-100 не NEW, а CONFIRMED" = Validation.hint(msg, "ru")
    end
  end

  describe "hint/2 – fallback behavior" do
    test "missing translation in glossary" do
      msg = {"has invalid format", validation: :format}

      assert "has invalid format" = Validation.hint(msg, "en")
    end

    test "missing :validation option entirely" do
      msg = {"something went wrong", foo: :bar}

      assert "something went wrong" = Validation.hint(msg, "en")
    end
  end
end
