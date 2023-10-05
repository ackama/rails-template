Rails.application.config.version = begin
  # checks ENV["SHA"] and the "./REVISION" file
  OkComputer::AppVersionCheck.new.version
rescue StandardError
  "N/A"
end

Rails.application.config.version_time = begin
  value = ENV.fetch("SHA_TIME") do
    # this file will be created by our capistrano deployments
    path = Rails.root.join("REVISION_TIME")

    raise StandardError unless File.exist?(path)

    File.read(path).chomp
  end
  Time.utc.at(value.to_i)
rescue StandardError
  nil
end
