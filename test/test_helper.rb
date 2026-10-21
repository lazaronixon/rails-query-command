# frozen_string_literal: true

require "minitest/autorun"
require "active_support"
require "active_support/test_case"
require "fileutils"
require "json"
require "open3"
require "tmpdir"

module QueryCommandTestHelper
  DUMMY_PATH = File.expand_path("dummy", __dir__)
  GEMFILE = File.expand_path("../Gemfile", __dir__)

  # A migrated copy of test/dummy, built once per run and copied for each test
  # so every test gets a fresh database, like railties' isolated app tests.
  def self.template_path
    @template_path ||= begin
      path = Dir.mktmpdir("query-command-template")
      Minitest.after_run { FileUtils.rm_rf(path) }
      FileUtils.cp_r("#{DUMMY_PATH}/.", path)
      run_rails(path, "db:migrate")
      path
    end
  end

  def self.run_rails(app_path, *args, allow_failure: false)
    env = { "BUNDLE_GEMFILE" => GEMFILE, "RAILS_ENV" => "development" }
    stdout, stderr, status = Open3.capture3(env, "bin/rails", *args, chdir: app_path)

    if !status.success? && !allow_failure
      raise "bin/rails #{args.join(" ")} failed:\n#{stdout}#{stderr}"
    end

    stdout + stderr
  end

  attr_reader :app_path

  def build_app
    @app_path = Dir.mktmpdir("query-command-app")
    FileUtils.cp_r("#{QueryCommandTestHelper.template_path}/.", app_path)
    FileUtils.mkdir_p(File.join(app_path, "tmp"))
  end

  def teardown_app
    FileUtils.rm_rf(app_path) if app_path
  end

  def app_file(path, contents)
    file = File.join(app_path, path)
    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, contents)
  end

  def rails(*args, allow_failure: false)
    QueryCommandTestHelper.run_rails(app_path, *args, allow_failure: allow_failure)
  end
end
