Rails.application.config.version = begin
  # checks ENV["SHA"] and the "./REVISION" file
  OkComputer::AppVersionCheck.new.version
rescue StandardError
  "N/A"
end
