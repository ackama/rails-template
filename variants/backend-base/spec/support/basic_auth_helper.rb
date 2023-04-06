module BasicAuthHelper
  module Controller
    def log_in_with_basicauth(
      user = ENV.fetch("HTTP_BASIC_AUTH_USERNAME", nil),
      pass = ENV.fetch("HTTP_BASIC_AUTH_PASSWORD", nil)
    )
      return unless user && pass

      request.env["HTTP_AUTHORIZATION"] = ActionController::HttpAuthentication::Basic.encode_credentials(user, pass)
    end
  end

  module Request
    def log_in_with_basicauth(
      user = ENV.fetch("HTTP_BASIC_AUTH_USERNAME", nil),
      pass = ENV.fetch("HTTP_BASIC_AUTH_PASSWORD", nil)
    )
      return unless user && pass

      default_options[:headers] ||= {}.with_indifferent_access
      default_options[:headers]["HTTP_AUTHORIZATION"] =
        ActionController::HttpAuthentication::Basic.encode_credentials(user, pass)
    end
  end

  module System
    def log_in_with_basicauth(
      user = ENV.fetch("HTTP_BASIC_AUTH_USERNAME", nil),
      pass = ENV.fetch("HTTP_BASIC_AUTH_PASSWORD", nil)
    )
      return unless user && pass

      case Capybara.current_driver
      when :rack_test
        page.driver.browser.basic_authorize(user, pass)
      when :chrome
        page.driver.browser.devtools.network.enable
        page.driver.browser.devtools.send_cmd(
          "Network.setExtraHTTPHeaders",
          headers: { "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(user, pass) }
        )
      else
        fail "Unrecognized driver #{Capybara.current_driver}"
      end
    end
  end
end

RSpec.configure do |config|
  config.include(BasicAuthHelper::Request, type: :request)
  config.include(BasicAuthHelper::Controller, type: :controller)
  config.include(BasicAuthHelper::System, type: :system)
end
