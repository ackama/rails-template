class Auditor
  class Event
    def initialize(current_user:, remote_ip:, event_info:, timestamp: Time.zone.now)
      @current_user = current_user
      @remote_ip = remote_ip
      @event_info = event_info

      # convert timestamp from the application TZ to UTC for consistency in the event log
      @timestamp = timestamp.utc
    end

    def to_h
      {
        event_name: self.class.to_s,
        user_id: @current_user ? @current_user.id : nil,
        remote_ip: @remote_ip,
        timestamp: @timestamp.iso8601,
        details: @event_info,
        description: description
      }
    end

    def to_json(*_args)
      to_h.to_json
    end

    ##
    # Child classes are expected to override this method to customise their
    # output
    #
    def description
      fail "Child classes of Auditor::Event must implement a custom description"
    end
  end
end
