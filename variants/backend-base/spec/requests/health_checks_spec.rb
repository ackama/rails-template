# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Automated health checks", type: :request do
  subject { response.body }

  let(:username) { ENV.fetch("HEALTHCHECK_HTTP_BASIC_AUTH_USERNAME") { ENV.fetch("HTTP_BASIC_AUTH_USERNAME", nil) } }
  let(:password) { ENV.fetch("HEALTHCHECK_HTTP_BASIC_AUTH_PASSWORD") { ENV.fetch("HTTP_BASIC_AUTH_PASSWORD", nil) } }

  before do
    log_in_with_basicauth(username, password)

    get "/healthchecks/all"
  end

  it { is_expected.to include("database: PASSED") }
  it { is_expected.to include("default: PASSED") }
end
