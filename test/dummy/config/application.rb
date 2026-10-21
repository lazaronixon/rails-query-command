require_relative "boot"

require "rails"
require "active_record/railtie"

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = "dummy"
    config.logger = Logger.new(nil)
  end
end
