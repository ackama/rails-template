require "rails_helper"

RSpec.describe AuditLog do
  let(:user) { Struct.new("FakeUser", :id).new(123) }
  let(:remote_ip) { "::1" }
  let(:timestamp_in_app_tz) { Time.zone.now }
  let(:expected_timestamp) { timestamp_in_app_tz.utc.iso8601 }
  let(:rails_log_output) { "" }
  let(:phase_of_moon) { "first-quarter" }

  describe ".log_example_event" do
    around do |example|
      old_logger = Rails.application.config.audit_logger
      Rails.application.config.audit_logger = build_capturing_logger(rails_log_output)
      example.run
      Rails.application.config.audit_logger = old_logger
    end

    it "logs the expected line to the Rails log" do
      expected_json = {
        event_type: AuditLog::EXAMPLE_LABEL,
        event_context: {
          remote_ip: remote_ip,
          user_id: user.id,
          phase_of_moon: phase_of_moon
        },
        event_created_at: expected_timestamp
      }.to_json
      expected_output = "#{expected_json}\n"

      described_class.log_example_event(
        current_user: user,
        remote_ip: remote_ip,
        phase_of_moon: phase_of_moon,
        timestamp: timestamp_in_app_tz
      )

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
    logger.formatter = AuditLogLogFormatter.new
    logger
  end
end
