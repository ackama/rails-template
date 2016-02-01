# Capybara + poltergeist allow JS testing via headless webkit
require "capybara/rails"
require "capybara/poltergeist"
require 'capybara/rspec'
Capybara.javascript_driver = :poltergeist

RSpec.configure do |config|
  config.include Capybara::DSL, type: :feature
end
