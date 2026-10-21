# frozen_string_literal: true

require_relative "lib/rails_query_command/version"

Gem::Specification.new do |spec|
  spec.name = "rails-query-command"
  spec.version = RailsQueryCommand::VERSION
  spec.authors = [ "Lazaro Nixon" ]
  spec.email = [ "koombea.lazaro@homebot.ai" ]

  spec.summary = "Backport of `bin/rails query` (read-only JSON database queries) for Rails 7.2, 8.0 and 8.1."
  spec.description = <<~DESC
    Adds the `bin/rails query` command from Rails main (rails/rails#57156) to apps running
    Rails 7.2, 8.0 and 8.1. Runs Active Record expressions or raw SQL against a read-only
    connection and prints structured JSON, with pagination and schema/model introspection.
  DESC
  spec.homepage = "https://github.com/rails/rails/pull/57156"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir["lib/**/*", "README.md", "CHANGELOG.md", "LICENSE.txt"]
  spec.require_paths = [ "lib" ]

  # Rails 8.2 ships this command in railties; drop the gem when upgrading.
  spec.add_dependency "railties", ">= 7.2", "< 8.2"
  spec.add_dependency "activerecord", ">= 7.2", "< 8.2"
end
