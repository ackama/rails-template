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

RSpec.describe Auditor do
  let(:user) { FakeUser.new(123) }
  let(:remote_ip) { "::1" }
  let(:event_specific_details) { { email: "t.rex@dinosauria.com", phone_number: "1234567890" } }
  let(:timestamp_in_app_tz) { Time.zone.now }
  let(:expected_timestamp) { timestamp_in_app_tz.utc.iso8601 }
  let(:event) do
    TestEvent.new(
      current_user: user,
      remote_ip: remote_ip,
      event_info: event_specific_details,
      timestamp: timestamp_in_app_tz
    )
  end
  let(:rails_log_output) { "" }

  describe "#log" do
    around do |example|
      old_logger = Rails.application.config.audit_logger
      Rails.application.config.audit_logger = build_capturing_logger(rails_log_output)
      example.run
      Rails.application.config.audit_logger = old_logger
    end

    it "logs the expected line to the Rails log" do
      expected_json = {
        event_name: "TestEvent",
        user_id: user.id,
        remote_ip: remote_ip,
        timestamp: expected_timestamp,
        details: event_specific_details,
        description: "Test event happened"
      }.to_json
      expected_output = "#{expected_json}\n"

      described_class.log(event)

      expect(rails_log_output).to eq(expected_output)
    end
  end

  ##
  # Build a ruby Logger object which will store every message sent to it in
  # the provided String rather than printing it to a file or console.
  #
  # Use the same custom log formatter we use for the rest of the application
  #
  def build_capturing_logger(str)
    logger = Logger.new(StringIO.new(str))
    logger.formatter = AuditorLogFormatter.new
    logger
  end
end
