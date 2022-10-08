require "rails_helper"

class TestEvent < Auditor::Event
  def description
    "Test event happened"
  end
end

class FakeUser
  attr_reader :id

  def initialize(id)
    @id = id
  end
end

RSpec.describe Auditor::Event do
  subject(:event) do
    TestEvent.new(
      current_user: user,
      remote_ip: remote_ip,
      event_info: event_specific_details,
      timestamp: timestamp
    )
  end

  let(:user) { FakeUser.new(123) }
  let(:remote_ip) { "::1" }
  let(:event_specific_details) { { email: "t.rex@dinosauria.com", phone_number: "1234567890" } }
  let(:timestamp) { Time.zone.now }
  let(:expected_hash_representation) do
    {
      user_id: user.id,
      remote_ip: remote_ip,
      timestamp: timestamp.utc.iso8601,
      event_name: "TestEvent",
      description: "Test event happened",
      details: event_specific_details
    }
  end

  describe ".to_h" do
    it "returns the expected hash" do
      expect(event.to_h).to eq(expected_hash_representation)
    end
  end
end
