# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Automated health checks" do
  subject { response.body }

  before { get "/healthchecks/all" }

  it { is_expected.to include("database: PASSED") }
  it { is_expected.to include("default: PASSED") }
end
