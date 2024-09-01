##
# The log_* class methods are the intended public interface for this class. You
# should create a method to build each kind of auditable event in your system.
#
# The params of the method decide what context is required (and what is
# optional) for each event (context can and will vary between events).
#
# The class method will take the given params, transform them as required and
# create an instance of AuditLog from them which it will immediately send to the
# designated log destination.
#
# Example usage:
#
#   # The "user signed in" event requires details of the current user and the
#   # remote IP address they signed in from
#   AuditLog.log_user_sign_in(current_user: current_user, remote_ip: request.remote_ip)
#
#   # The "An instance of Foo was created" event needs to know the user who created
#   # it and the id of the Foo which was created
#   my_foo = Foo.new(...)
#   AuditLog.log_create_foo(current_user: current_user, foo_id: my_foo.id)
#
class AuditLog
  EXAMPLE_LABEL = "you_should_delete_this_event_type_when_you_have_real_events".freeze
  # USER_SIGN_IN_LABEL = "user_sign_in".freeze
  # CREATE_FOO_LABEL = "create_foo_record".freeze

  ##
  # An example event which you should delete as soon as you have real events in
  # the system.
  #
  # This event needs to know the user who triggered it, their remote IP and, for
  # $reasons, the phase of the moon.
  #
  def self.log_example_event(current_user:, remote_ip:, phase_of_moon:, timestamp: Time.zone.now)
    new(
      type: EXAMPLE_LABEL,
      context: {
        remote_ip:,
        user_id: current_user.id,
        phase_of_moon:
      },
      timestamp:
    ).send_to_log
  end

  # def self.log_user_sign_in(current_user:, remote_ip:)
  #   new(
  #     type: USER_SIGN_IN_LABEL,
  #     context: {
  #       remote_ip: remote_ip,
  #       user_id: current_user.id
  #     }
  #   ).send_to_log
  # end

  # def self.log_create_foo(current_user:, foo_id:)
  #   new(
  #     type: CREATE_FOO_LABEL,
  #     context: {
  #       remote_ip: remote_ip,
  #       user_id: current_user.id,
  #       foo_id: foo_id
  #     }
  #   ).send_to_log
  # end

  ##
  # The intent is that you use one of the class methods to build an instance
  # tailored to a specific event rather than direclty creating instances of this
  # class.
  #
  def initialize(type:, context:, timestamp: Time.zone.now)
    @context = context
    @type = type

    # Create timestamp in UTC for consistency in the event log
    @timestamp = timestamp.utc
  end

  def to_h
    {
      event_type: @type,
      event_context: @context,
      event_created_at: @timestamp.iso8601
    }
  end

  def send_to_log
    Rails.application.config.audit_logger.info(to_h.to_json)
  end
end
