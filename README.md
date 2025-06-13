# Glossary

**Minimalistic semantic translation system for Elixir apps.**

Glossary is a lightweight and expressive alternative to Gettext for modern Elixir applications — especially Phoenix LiveView.  
It embraces semantic lexemes, YAML lexicons, and compile-time localization with a simple and explicit API.

Each YAML file acts as a lexicon — a mapping of semantic keys (lexemes) to localized values (expressions) for a given language.  
All lexicons are compiled into the module at build time, enabling fast and predictable lookups at runtime.

---

- [🧱 Concept](#-concept)
- [✨ Features](#-features)
- [📄 Lexicons (YAML)](#-lexicons-yaml)
- [🚀 Quick Start](#-quick-start)
- [💡 API](#-api)
- [📚 Best Practices](#-best-practices)
- [🏛️ Philosophy](#-philosophy)
- [🔍 Comparison with Gettext](#-comparison-with-gettext)
- [🧩 Using with Ecto](#-using-with-ecto)
- [🧠 Acknowledgments](#-acknowledgments)
- [📬 Feedback](#-feedback)

---

## 🧱 Concept

A **lexeme** is a minimal semantic unit — a key like `"game.won"`.  
An **expression** is its localized realization — a string like `"You won!"`.  
A **lexicon** is a YAML file that maps lexemes to expressions for a specific language.

Together, lexicons form a **glossary** — a complete set of localized meanings.

---

## ✨ Features

- 🧠 **Semantic keys** — Use lexemes like `"game.score"`, not literal strings.
- 🔄 **Runtime interpolation** — Simple bindings with `{{key}}` syntax.
- ⚡ **Live reloadable** — Load translations dynamically, perfect for LiveView.
- 📄 **YAML-first** — Intuitive, version-friendly format.
- 🧪 **No hidden magic** — Only explicit macros for setup, no DSLs, no runtime surprises.

---

## 📄 Lexicons (YAML)

Each YAML file represents a **lexicon** — a set of localized expressions.  
Lexicons are merged into a single lookup table keyed by `"language.lexeme"`.

```yaml
# game.en.yml
game:
  won: "You won!"
  lost: "Game over."
  score: "Your score: {{score}}"

# game.ru.yml
game:
  won: "Вы победили!"
  lost: "Игра окончена."
  score: "Ваш счёт: {{score}}"

# user.en.yml
user:
  greeting: "Hello, {{name}}!"

# user.ru.yml
user:
  greeting: "Привет, {{name}}!"
```

---

## 🚀 Quick Start

1. Add to your project

# mix.exs
```elixir
    def deps do
      [
        {:glossary, "~> 0.1"}
      ]
    end
```

2. Define a module with glossary and specify lexicon files

```elixir
defmodule MyAppWeb.Live.Game.Show do
  use Glossary, ["game", "../users/user", "../common"]
end
```

This will compile:
	•	game.en.yml, game.ru.yml
	•	user.en.yml, user.ru.yml
	•	common.en.yml, common.ru.yml

3. Use in LiveView templates

```elixir
<%= MyAppWeb.Live.Game.Show.t("game.score", @locale, score: 42) %>
```

4. Missing translation?

You’ll see the full key on the page (e.g., en.game.score) and a warning in logs:

```shell
[warning] [Glossary] Missing key: en.game.score
```

5. Add translation and reload

```yaml
# game.en.yml
game:
  score: "Your score: {{score}}"
```

No recompilation needed.

---

## 💡 API

t(lexeme, locale)
t(lexeme, locale, bindings)
- Falls back to lexeme if no translation is found.
- Interpolates placeholders like {{score}} with values from bindings.

---

## 🧩 Using with Ecto

Glossary includes seamless support for Ecto.Changeset errors.

### Setup

```elixir
defmodule MyAppWeb.CoreComponents do
  use Glossary.Ecto, ["validation"]

# Add a locale attribute to your input component:

  attr :locale, :string, default: "en"
  def input(%{field: %HTML.FormField{} = field} = assigns) do
    ...
    |> assign(:errors, Enum.map(field.errors, &hint(&1, assigns.locale)))
    ...
  end
  ...
end
```

### In your custom validation:

```elixir
add_error(
  changeset,
  :field,
  "you're doing it wrong",
  foo: "bar",
  validation: :foobar
)
```

If there’s no translation yet, the fallback message will be shown ("you're doing it wrong"), and a warning will be logged.


```yaml
validation:
  foobar: "you're doing {{foo}} wrong"
```

Example usage in form (important! add locale):

```elixir
<.input
  field={@form[:body]}
  action={@form.source.action}
  locale={@locale}
  type="text"
/>
```

Example YAML (see: [validation.en.yml](https://github.com/sovetnik/glossary/blob/main/test/support/locales/validation.en.yml))

---

## 📚 Best Practices
- ✅ Use semantic keys: "user.greeting" > "welcome_text_1"
- 📁 Group by domain: user, game, import, etc.
- 🧩 Prefer flat 2-level keys: domain.key
- 🔑 Avoid file-based logic — only lexemes and language matter
- 🪄 Use {{key}} placeholders for dynamic values

---

## 🏛️ Philosophy

Glossary was built for **dynamic apps** — like those using Phoenix LiveView — where UI, state, and translations often evolve together.

### 🔍 Comparison with Gettext
Glossary is built for interactive, reactive, hot-reloaded systems.
Gettext was designed for monolithic, statically compiled apps in the 1990s. 
Phoenix LiveView is dynamic, reactive, and often developer-translated. 
Glossary brings translation into the runtime flow of development.

| Feature              | Glossary            | Gettext             |
|----------------------|---------------------|---------------------|
| ✅ Semantic keys      | Yes (`"home.title"`) | No (uses msgid)     |
| ✏️ YAML format        | Yes                  | No (.po files)      |
| ♻️ Live reload        | Easy                 | Needs recompilation |
| 📦 Runtime API        | Simple `t/2`, `t/3`  | Macro-based         |
| 🧪 Dev experience     | Transparent          | Magic/macros        |

---

### Why move beyond gettext?

- You want **declarative keys** and **semantic structure**
- You want to **edit translations live**
- You don’t want to manage `.po` files or run compilers
- You want your **UI and language logic to stay in sync**

---

## 🧠 Acknowledgments

Inspired by real-world needs of building modern Phoenix LiveView apps with:
- ✨ Declarative UIs
- 🔁 Dynamic state
- 🛠️ Developer-driven i18n

---

## 📬 Feedback

Glossary is small, hackable, and stable — and we’re open to ideas.
Raise an issue, suggest a feature, or just use it and tell us how it goes.

Let your translations be as clean as your code.
