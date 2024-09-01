require "rails_helper"

RSpec.describe AuditLog do
  let(:user) { Struct.new("FakeUser", :id).new(123) }
  let(:remote_ip) { "::1" }
  let(:timestamp_in_app_tz) { Time.zone.now }
  let(:expected_timestamp) { timestamp_in_app_tz.utc.iso8601 }
  let(:rails_log_output) { "" }
  let(:phase_of_moon) do
    <<~EO_DATA
      multiline
      value
      first
      quarter
    EO_DATA
  end

  describe ".log_example_event" do
    around do |example|
      old_logger = Rails.application.config.audit_logger
      Rails.application.config.audit_logger = build_capturing_logger(rails_log_output)
      example.run
      Rails.application.config.audit_logger = old_logger
    end

    it "logs the expected line to the Rails log" do
      described_class.log_example_event(
        current_user: user,
        remote_ip:,
        phase_of_moon:,
        timestamp: timestamp_in_app_tz
      )

      # newlines within JSON values are encoded as the two characters `\n`. A
      # real newline character is appended to the end of the log line.
      expected_output = "{\"event_type\":\"you_should_delete_this_event_type_when_you_have_real_events\",\"event_context\":{\"remote_ip\":\"::1\",\"user_id\":123,\"phase_of_moon\":\"multiline\\nvalue\\nfirst\\nquarter\\n\"},\"event_created_at\":\"#{expected_timestamp}\"}\n" # rubocop:disable Layout/LineLength

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
