# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    config.load_defaults 7.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.generators.system_tests = nil
    config.generators do |g|
      g.skip_routes true
      g.helper false
      g.test_framework nil
    end
    config.time_zone = 'Tokyo'
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_codereview_session'
  end
end
