# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Automated health checks", type: :request do
  before(:all) { get "/healthchecks/all" }

  subject { response.body }

  it { is_expected.to include("database: PASSED") }

  it { is_expected.to include("default: PASSED") }

  it { is_expected.to include("mailing: PASSED") }

  it { is_expected.to include("redis: PASSED") }
end
