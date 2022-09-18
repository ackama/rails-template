mailer_regex = /config\.action_mailer\.raise_delivery_errors = false\n/

comment_lines "config/environments/development.rb", mailer_regex
insert_into_file "config/environments/development.rb", after: mailer_regex do
  <<-RUBY

  # Ensure mailer works in development.
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.action_mailer.asset_host = "http://localhost:3000"

  # Raise an error if we try and look up a missing translation
  config.i18n.raise_on_missing_translations = true
  RUBY
end

gsub_file "config/environments/development.rb",
          "join('tmp', 'caching-dev.txt')",
          'join("tmp/caching-dev.txt")'
