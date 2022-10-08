require "rails_helper"

RSpec.describe Auditor::Event::Example do
  subject(:event) do
    described_class.new(
      current_user: user,
      remote_ip: fake_remote_ip,
      event_info: event_specific_details,
      timestamp: test_timestamp
    )
  end

  it "implements the expected description" do
    event = described_class.new(current_user: nil, remote_ip: "::1", event_info: {})

    expect(event.description).to eq("The example event happened")
  end
end
