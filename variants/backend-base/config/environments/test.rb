gsub_file "config/environments/test.rb",
          "config.eager_load = false",
          "config.eager_load = defined?(SimpleCov).present?"

insert_into_file \
  "config/environments/test.rb",
  after: /config\.action_mailer\.delivery_method = :test\n/ do
  <<-RUBY

  # Ensure mailer works in test
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.action_mailer.asset_host = "http://localhost:3000"

  # Raise an error if we try and look up a missing translation
  config.i18n.raise_on_missing_translations = true
  RUBY
end
