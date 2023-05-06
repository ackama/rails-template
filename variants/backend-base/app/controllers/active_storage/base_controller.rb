# frozen_string_literal: true

# The base class for all Active Storage controllers.
# Copied from
# https://github.com/rails/rails/blob/main/activestorage/app/controllers/active_storage/base_controller.rb
# :nocov:
class ActiveStorage::BaseController < ActionController::Base # rubocop:disable Rails/ApplicationController
  include ActiveStorage::SetCurrent

  protect_from_forgery with: :exception

  before_action :authenticated?

  self.etag_with_template_digest = false

  private

  # ActiveStorage defaults to security via obscurity approach to serving links
  # If this is acceptable for your use case then this authenticable test can be
  # removed. If not then code should be added to only serve files appropriately.
  # https://edgeguides.rubyonrails.org/active_storage_overview.html#proxy-mode
  def authenticated?
    fail StandardError, "No authentication is configured for ActiveStorage"
  end
end
# :nocov:
