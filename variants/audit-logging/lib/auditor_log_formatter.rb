require "logger"
##
# We want everything which is sent to `Rails.logger` to be parsable as JSON.
# This means we need to remove the Timestamp and severity prefix from the log
# lines that Rails normally generates. We do this with this customer Log
# formatter - see `config/application.rb` for where Rails is instructed to use
# it.
#
class AuditorLogFormatter < Logger::Formatter
  ##
  # The public API of this function is defined by `Logger::Formatter`
  #
  def call(_severity, _timestamp, _progname, msg)
    "#{msg}\n"
  end
end
