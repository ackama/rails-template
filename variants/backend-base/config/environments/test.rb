insert_into_file! \
  "config/environments/test.rb",
  after: /config\.action_mailer\.delivery_method = :test\n/ do
  <<-RUBY

  # Ensure mailer works in test
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.asset_host = "http://localhost:3000"
  RUBY
end

gsub_file! "config/environments/test.rb",
           'config.action_mailer.default_url_options = { host: "www.example.com" }',
           'config.action_mailer.default_url_options = { host: "localhost:3000" }'

gsub_file! "config/environments/test.rb",
           "# config.i18n.raise_on_missing_translations = true",
           "config.i18n.raise_on_missing_translations = true"

gsub_file! "config/environments/test.rb",
           "config.action_controller.raise_on_missing_callback_actions = true",
           "# config.action_controller.raise_on_missing_callback_actions = true"
