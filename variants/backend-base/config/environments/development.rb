gsub_file! "config/environments/development.rb",
           <<-RUBY,
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
RUBY
           <<-RUBY
  # Ensure mailer works in development.
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.asset_host = "http://localhost:3000"
RUBY

gsub_file! "config/environments/development.rb",
           "# config.i18n.raise_on_missing_translations = true",
           "config.i18n.raise_on_missing_translations = true"

gsub_file! "config/environments/development.rb",
           "config.action_controller.raise_on_missing_callback_actions = true",
           "# config.action_controller.raise_on_missing_callback_actions = true"
