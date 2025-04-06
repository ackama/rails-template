#!/usr/bin/env ruby

def ensure_no_duplicate_config_lines_in_environment_files
  Dir.glob("**/config/environments/*.rb").each do |file|
    # @type [Array<String>]
    properties = []

    in_condition = false

    File.readlines(file).each do |line|
      in_condition = true if line.strip.start_with?("if")
      in_condition = false if line.strip == "end"

      next if in_condition

      line.match(/config\.[a-zA-Z_]+ = /) do |match|
        property = match[0]
        if properties.include?(property)
          puts "#{file}: #{line}"
        else
          properties << property
        end
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  Dir.chdir(ARGV[0]) do
    ensure_no_duplicate_config_lines_in_environment_files
  end
end
