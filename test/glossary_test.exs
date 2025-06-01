defmodule GlossaryTest do
  use ExUnit.Case, async: true

  defmodule Phrasebook do
    use Glossary, ["../test/support/locales/example", "not_exists"]
  end

  describe "using adds functions" do
    test "only t/2 and t/3 are defined" do
      functions = Phrasebook.__info__(:functions)
      assert Enum.sort(functions) == Enum.sort([{:t, 2}, {:t, 3}])
    end
  end

  describe "t/2" do
    test "returns English translations" do
      assert Phrasebook.t("count.first", "en") == "First"
      assert Phrasebook.t("count.second", "en") == "Second"
    end

    test "returns Russian translations" do
      assert Phrasebook.t("count.first", "ru") == "Первый"
      assert Phrasebook.t("count.second", "ru") == "Второй"
    end

    test "falls back to key if missing" do
      assert Phrasebook.t("unknown.key", "ru") == "ru.unknown.key"
    end
  end

  describe "t/3" do
    test "interpolates bindings in English" do
      assert Phrasebook.t("messages.score", "en", score: 42) == "Score: 42"
      assert Phrasebook.t("messages.hello", "en", name: "Alice") == "Hello, Alice!"
    end

    test "interpolates bindings in Russian" do
      assert Phrasebook.t("messages.score", "ru", score: 100) == "Счёт: 100"
      assert Phrasebook.t("messages.hello", "ru", name: "Алиса") == "Привет, Алиса!"
    end

    test "ignores extra bindings" do
      assert Phrasebook.t("messages.hello", "en", name: "Bob", extra: "ignored") == "Hello, Bob!"
    end

    test "does not interpolate missing keys" do
      assert Phrasebook.t("messages.hello", "en", foo: "Bar") == "Hello, {{name}}!"
    end
  end
end
