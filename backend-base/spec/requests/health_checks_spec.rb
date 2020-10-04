# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Automated health checks", type: :request do
  before(:each) { get "/healthchecks/all" }
  subject { response.body }
  it { is_expected.to include("database: PASSED") }
  it { is_expected.to include("default: PASSED") }
end
