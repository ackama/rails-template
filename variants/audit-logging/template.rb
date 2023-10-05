source_paths.unshift(File.dirname(__FILE__))

copy_file("variants/audit-logging/lib/auditor_log_formatter.rb", "lib/auditor_log_formatter.rb")
copy_file("variants/audit-logging/services/audit_log.rb", "app/services/audit_log.rb")
copy_file("variants/audit-logging/spec/services/audit_log_spec.rb", "spec/services/audit_log_spec.rb")

insert_into_file "app/controllers/application_controller.rb", after: /^  end/ do
  <<-RUBY


    ##
    # Example of generating an audit log event
    #
    # def note_example_event_in_audit_log
    #   AuditLog.log_user_sign_in(current_user: current_user, remote_ip: request.remote_ip)
    # end
  RUBY
end

prepend_to_file "config/application.rb" do
  <<~RUBY
    require_relative "../lib/auditor_log_formatter"
  RUBY
end

insert_into_file "config/application.rb", before: /^  end/ do
  <<-RUBY

    if ENV["RAILS_LOG_TO_STDOUT"].present?
      config.audit_logger = Logger.new($stdout, formatter: AuditLogLogFormatter.new)
    else
      config.audit_logger = Logger.new("log/audit.log", formatter: AuditLogLogFormatter.new)
    end
  RUBY
end
