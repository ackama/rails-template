class Auditor
  ##
  # In future, Audit logs may need to be sent somewhere else (or to multiple
  # locations) so we encapsulate the details of where they go behind this
  # (currently very thin) interface.
  #
  def self.log(event)
    Rails.application.config.audit_logger.info(event.to_json)
  end
end
