# frozen-string-literal: true

# RAILS_SECRET_KEY_BASE should be set to something other than its value in example.env

if Rails.env.production? && Rails.root.join("example.env").read.include?(ENV.fetch("RAILS_SECRET_KEY_BASE"))
  raise "RAILS_SECRET_KEY_BASE is unchanged from example.env. " \
        "Generate a new one with `bundle exec rails secret`"
end
