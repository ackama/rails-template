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
      remote_ip: fake_remote_ip,
      event_info: event_specific_details,
      timestamp: test_timestamp
    )
  end

  let(:user) { FakeUser.new(123) }
  let(:fake_remote_ip) { "::1" }
  let(:event_specific_details) { { email: "t.rex@dinosauria.com", phone_number: "1234567890" } }
  let(:test_timestamp) { Time.zone.now }

  it "requires child classes to implement #description" do
    event = described_class.new(
      current_user: user,
      remote_ip: fake_remote_ip,
      event_info: event_specific_details,
      timestamp: test_timestamp
    )
    expect { event.description }.to raise_error("Child classes of Auditor::Event must implement a custom description")
  end

  describe ".to_h" do
    it "returns the expected hash" do
      expect(event.to_h).to eq(
        {
          user_id: user.id,
          remote_ip: fake_remote_ip,
          timestamp: test_timestamp.utc.iso8601,
          event_name: "TestEvent",
          description: "Test event happened",
          details: event_specific_details
        }
      )
    end

    it "handles missing current_user" do
      event = TestEvent.new(
        current_user: nil,
        remote_ip: fake_remote_ip,
        event_info: event_specific_details,
        timestamp: test_timestamp
      )

      expect(event.to_h).to eq(
        {
          user_id: nil,
          remote_ip: fake_remote_ip,
          timestamp: test_timestamp.utc.iso8601,
          event_name: "TestEvent",
          description: "Test event happened",
          details: event_specific_details
        }
      )
    end
  end
end
