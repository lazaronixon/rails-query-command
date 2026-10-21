# rails-query-command

A backport of `bin/rails query` for **Rails 7.2, 8.0 and 8.1**.

`rails query` was added to Rails in [rails/rails#57156](https://github.com/rails/rails/pull/57156) and is planned for Rails 8.2. It runs read-only database queries and prints structured JSON, so agents and scripts can query a database (for example with `kamal app exec`) without risking writes or parsing free-form `rails runner` output.

This gem ships the command exactly as it is on Rails `main` (commit [`e9aab74b13`](https://github.com/rails/rails/commit/e9aab74b13)), including the fixes merged after the original PR.

## Installation

```ruby
# Gemfile
gem "rails-query-command"
```

You don't need any setup. `bin/rails` finds the command on the load path, and it shows up in `bin/rails --help`.

**Upgrading to Rails 8.2:** the command is built into Rails 8.2, so remove this gem when you upgrade. The gemspec requires `railties < 8.2`, so Bundler will remind you.

## Usage

```bash
# Active Record expressions
bin/rails query "Account.where(plan: 'premium').limit(10)"
bin/rails query "Account.count"

# Raw SQL
bin/rails query --sql "SELECT id, name FROM accounts"

# Read from stdin
echo "Account.first" | bin/rails query -

# Pagination (default: --page 1 --per 100, max per page 10000)
bin/rails query "Account.all" --page 2 --per 50

# Introspection
bin/rails query schema              # list tables
bin/rails query schema accounts     # columns, indexes, enums, associations
bin/rails query models              # models with table names and associations
bin/rails query explain "Account.where(plan: 'premium')"

# Pick a database config in a multi-database app
bin/rails query "Account.count" --database primary_replica

# Pretty-print / CSV with jq
bin/rails query "Account.first" | jq
bin/rails query "Account.limit(5)" | jq -r '.rows[] | @csv'
```

The output looks like this:

```json
{
  "columns": ["id", "name", "plan"],
  "rows": [[1, "Acme", "premium"], [2, "Widgets Co", "premium"]],
  "meta": {
    "row_count": 2,
    "query_time_ms": 4.2,
    "page": 1,
    "per_page": 100,
    "has_more": false,
    "sql": "SELECT \"accounts\".* FROM \"accounts\" WHERE \"accounts\".\"plan\" = 'premium' LIMIT 101"
  }
}
```

Errors are also JSON, written to stderr, and the command exits with status 1:

```json
{"error": "Write query attempted while in readonly mode: INSERT INTO posts (title) VALUES ('x') LIMIT 101", "meta": {"query_time_ms": 0}}
```

## Safety

- If a `reading` role is configured, queries run against it. Otherwise they run inside `while_preventing_writes`, so `INSERT`, `UPDATE`, `DELETE`, `Post.delete_all` and `record.update!` are rejected.
- Active Record expressions are evaluated as Ruby, so they're as trusted as `rails runner` and `rails console`. Write protection covers the database, not arbitrary Ruby. Use `--sql` when you only want SQL to run.
- Every query is wrapped in a `query.rails` `ActiveSupport::Notifications` event with an `expression` payload, which you can use for audit logging:

  ```ruby
  ActiveSupport::Notifications.subscribe("query.rails") do |event|
    Rails.logger.info("rails query: #{event.payload[:expression]}")
  end
  ```

## Development

```bash
bundle install
bundle exec rake test                                              # Rails 8.1
RAILS_VERSION=8.0 bundle update && RAILS_VERSION=8.0 bundle exec rake test
RAILS_VERSION=7.2 bundle update && RAILS_VERSION=7.2 bundle exec rake test
```

The tests are ported from `railties/test/commands/query_test.rb`. Each test runs the real `bin/rails query` against a fresh copy of the app in `test/dummy`.

## License

MIT. The command and its tests come from [Ruby on Rails](https://github.com/rails/rails) and are © David Heinemeier Hansson. See `LICENSE.txt`.
