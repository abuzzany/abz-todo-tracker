# abz-todo-tracker

A small Rails 8.1 to-do tracker built on Hotwire (Turbo + Stimulus), with per-item
categories and a completion dashboard.

## Features

- **To-do items** with title, description, category, and completion state
  (`completed` + `completed_at`)
- **Categories** — free-form, case-insensitive unique names; you can pick an
  existing category or type a new one inline when creating/editing an item.
  Deleting a category doesn't delete its items — they're just nullified back
  to "no category" (`Category has_many :to_do_items, dependent: :nullify`)
- **Dashboard chart** on the index page showing items completed per day,
  broken down by category (via [chartkick](https://chartkick.com/) and
  [groupdate](https://github.com/ankane/groupdate))
- JSON API for to-do items (`.json` variants of index/show, via Jbuilder)

## Tech stack

- Ruby 4.0.1 / Rails 8.1
- Hotwire: Turbo + Stimulus
- Tailwind CSS (`tailwindcss-rails`)
- SQLite (via `sqlite3` gem)
- Solid Queue / Solid Cache / Solid Cable for background jobs, caching, and
  Action Cable — no separate Redis dependency
- Minitest for tests (no RSpec)
- Deployed with [Kamal](https://kamal-deploy.org) (see `.kamal/`, `Dockerfile`)

## Getting started

Requires Ruby 4.0.1 (see `.tool-versions`).

```bash
bin/setup
```

This installs gems, prepares the database, and clears logs/tmp. It's
idempotent, and boots the app via `bin/dev` when it's done. Pass
`--skip-server` to skip that last step.

To just run the app:

```bash
bin/dev
```

This starts the Rails server and the Tailwind CSS watcher together (see
`Procfile.dev`). The app is served at http://localhost:3000.

## Running tests

```bash
bin/rails test              # unit + controller tests
bin/rails test:system       # Capybara/Selenium system tests (slower)
```

## Verify loop

Run in this order, cheapest first, before considering a change done:

1. `bin/rubocop -A` — autofix style (rubocop-rails-omakase)
2. `bin/rails test test/models/<file>_test.rb` — fastest signal for the file you touched
3. `bin/rails test` — full unit/controller suite
4. `bin/rails test:system` — slow; run before calling a task finished
5. Before opening a PR: `bin/brakeman --no-pager`, `bin/bundler-audit`, `bin/importmap audit`

CI (`.github/workflows/ci.yml`) runs all of the above (lint, security scans,
tests, system tests) on every push/PR to `main`.

## Domain model

```
Category
  has_many :to_do_items, dependent: :nullify
  validates :name, presence: true, uniqueness: { case_sensitive: false }

ToDoItem
  belongs_to :category, optional: true
  validates_presence_of :title
```

## Deployment

Deployed via Kamal — see `.kamal/` and the `Dockerfile`. Never run
`bin/kamal deploy` or touch `config/master.key` / `config/credentials*`
without explicit confirmation.
