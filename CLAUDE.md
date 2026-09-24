# CLAUDE.md

## Project
Rails 8.1 todo-tracker app: Hotwire (Turbo + Stimulus) for interactivity, Tailwind for styling,
SQLite for storage, Solid Queue/Cache/Cable for background/async concerns. Deployed via Kamal
(see `.kamal/`, `Dockerfile`). Minitest is the test framework — no RSpec.

Core domain: `ToDoItem belongs_to :category, optional: true` / `Category has_many :to_do_items,
dependent: :nullify` — deleting a category nullifies its items' category rather than deleting them.

## Setup
- `bin/setup` — installs gems, prepares the db, clears logs/tmp (idempotent; add `--skip-server` to
  not also boot `bin/dev`)
- `bin/dev` — runs the app: `bin/rails server` + `bin/rails tailwindcss:watch` (see `Procfile.dev`)

## Verify loop — run in this order, cheapest first
1. `bin/rubocop -A` — autofix style (rubocop-rails-omakase)
2. `bin/rails test test/models/<file>_test.rb` (or whichever file you touched) — fastest signal
3. `bin/rails test` — full unit/controller suite
4. `bin/rails test:system` — Capybara/Selenium; slow, run before calling a task finished
5. Before opening a PR: `bin/brakeman --no-pager`, `bin/bundler-audit`, `bin/importmap audit`

A change is not done until steps 1–3 are green. CI (`.github/workflows/ci.yml`) enforces all five —
don't skip 4–5 just because they're slow if the change touches views/JS or dependencies.

## Definition of done
- [ ] Test added/updated for the behavior change
- [ ] `bin/rails test` green, no new rubocop offenses
- [ ] `db/schema.rb` committed if a migration was added
- [ ] No unrelated files touched

## Stop conditions
- Same test failing after ~3 fix attempts → stop, state the hypothesis in plain terms, ask instead
  of continuing to guess.
- A rubocop autofix (`-A`) that touches files you didn't intend to change → stop and review the
  diff before proceeding, don't just re-run it.

## Harness / permissions
- Safe to run without asking: `bin/rails test*`, `bin/rubocop*`, `bin/brakeman`, `bin/bundler-audit`,
  `bin/importmap audit`, `bin/rails db:prepare`, `bin/setup`, `bin/dev`.
- Always ask first: `bin/rails db:migrate` outside `RAILS_ENV=test`, `bin/kamal deploy` (or anything
  under `.kamal/`), anything touching `config/master.key` or `config/credentials*`.

## Conventions
- Minitest + fixtures (`test/fixtures/*.yml`), not RSpec.
- Follow `rubocop-rails-omakase` defaults — let `bin/rubocop -A` format, don't hand-format against it.
- Turbo/Stimulus for interactivity; don't introduce a second JS framework.
- Migrations: add via `bin/rails generate migration`, always commit the resulting `db/schema.rb`.
