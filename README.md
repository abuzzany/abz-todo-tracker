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
- **Categories section** (`/categories`) to list, create, rename, and delete
  categories, with a count of the to-do items in each
- **Dashboard** (the root page, `to_do_items#index`):
  - **Completion streaks**: your current and longest run of consecutive days
    with at least one completed item. The current streak still counts through
    yesterday until today is over, so it doesn't drop to zero in the morning
    (`CompletionStreak`)
  - **Completion heatmap**: a GitHub-style grid of the last 52 weeks, with
    month labels and a Less/More legend. Hover a cell to see the full date and
    a per-category breakdown. On narrow screens it scrolls and opens on the
    most recent weeks
  - **Category filter** for the heatmap: All/per-category buttons
    (`?streak_category_id=`) that narrow the heatmap and show that
    category's current and longest streak. The filter swaps in a Turbo Frame
    without reloading the rest of the page
  - **Completions chart** showing items completed per day, as a total and
    broken down by category (via [chartkick](https://chartkick.com/) and
    [groupdate](https://github.com/ankane/groupdate))
  - **Paginated items table**: 15 items per page with Previous/Next links. The
    table is its own Turbo Frame, so paging doesn't reload the streaks, heatmap,
    or chart, and the selected streak category is kept. Invalid or
    out-of-range `?page=` values are clamped instead of raising an error
- JSON API for to-do items and categories (`.json` variants of the standard
  resource routes, via Jbuilder). `GET /to_do_items.json` is paginated the same
  way as the HTML table

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

### Sample data

```bash
bin/rails db:seed
```

This loads sample categories, open to-dos, and about 13 weeks of completion
history, including a current streak that ends today and a longer 16-day
streak in the past, so the dashboard has data to show. It only runs in
development, and it's idempotent: running it again updates the sample
records instead of creating duplicates.

### Docker (local development)

```bash
docker compose up                # app at http://localhost:3000 (server + Tailwind watcher)
docker compose run --rm test     # bin/rails test (no system tests: there's no browser in the container)
```

This builds `Dockerfile.dev` and bind-mounts the repo, so code changes reload
live. It runs `Procfile.dev.docker` instead of `bin/dev`. The production image
is the separate `Dockerfile`, which is deployed with Kamal.

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

CompletionStreak   # plain Ruby object, not a table
  #current / #longest from the dates on which items were completed
```

## Deployment

Deployed via Kamal — see `.kamal/` and the `Dockerfile`. Never run
`bin/kamal deploy` or touch `config/master.key` / `config/credentials*`
without explicit confirmation.
