source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version")

gem "rails", "7.0.2.4"
gem "puma", "~> 4.1"
gem "pg", "~> 1.1"
gem 'dotenv-rails', require: "dotenv/rails-now"
gem "bootsnap", require: false
gem "sassc-rails"
gem "webpacker"
gem "lograge"
gem "okcomputer"
gem "sentry-ruby"
gem "sentry-rails"

gem "rack-canonical-host", "~> 0.2.3"

group :development do
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "simplecov", require: false
  gem "rubocop", ">= 0.70.0", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "letter_opener"

  # Required in Rails 5 by ActiveSupport::EventedFileUpdateChecker
  gem "listen"
  gem "overcommit", ">= 0.37.0", require: false
end

group :development, :test do
  gem "bullet"
  gem "faker"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "pry-rails"
  gem "pry-byebug"
end

group :test do
  gem "capybara"
  gem "mock_redis"
  gem "selenium-webdriver"
  gem "webdrivers"

gem "lighthouse-matchers"
gem "axe-matchers"
end
gem "pundit"
