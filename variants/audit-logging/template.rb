source_paths.unshift(File.dirname(__FILE__))

copy_file("variants/audit-logging/lib/auditor_log_formatter.rb", "lib/auditor_log_formatter.rb")

copy_file("variants/audit-logging/services/auditor.rb", "app/services/auditor.rb")
directory("variants/audit-logging/services/auditor", "app/services/auditor")

copy_file("variants/audit-logging/spec/services/auditor_spec.rb", "spec/services/auditor_spec.rb")
directory("variants/audit-logging/spec/services/auditor", "spec/services/auditor")

insert_into_file "app/controllers/application_controller.rb", after: /^  end/ do
  <<-'RUBY'


    ##
    # Example of generating an audit log event for "Thing A"
    #
    # You can edit the shape of audit log events as your app requires.
    #
    # def note_thing_a_in_audit_log
    #   event = Auditor::Events::Example.new(
    #     current_user: current_user,
    #     remote_ip: request.remote_ip,
    #     event_info: { anything: "anything" } # event_info is a Hash of whatever else you need to store about the event
    #   )
    #   Auditor.log(event)
    # end
  RUBY
end

prepend_to_file "config/application.rb" do
  <<~RUBY
    require_relative "../lib/auditor_log_formatter"
  RUBY
end

insert_into_file "config/application.rb", before: /^  end/ do
  <<-'RUBY'

    config.audit_logger = Logger.new("log/audit.log", formatter: AuditorLogFormatter.new)
  RUBY
end
