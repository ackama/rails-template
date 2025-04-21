#!/usr/bin/env ruby

# Checks the given file for repeated "config.xyz = " lines
#
# @param [String] file
#
# @return [Array<String>]
def check_file_for_repeated_config_properties(file)
  # @type [Array<String>]
  seen = []
  # @type [Array<String>]
  duplicates = []
  in_condition = false

  File.readlines(file).each do |line|
    in_condition = true if line.strip.start_with?("if")
    in_condition = false if line.strip == "end"

    # ignore conditions for now
    next if in_condition

    line.match(/(config\.\w+) = /) do |match|
      duplicates << match[1] if seen.include?(match[1])

      seen << match[1]
    end
  end

  duplicates
end

# Checks each environment config file for duplicate config properties,
# as we should be reusing lines where possible to avoid confusion
# and reduce the diff when doing Rails upgrades on applications
def ensure_no_duplicate_config_lines_in_environment_files
  # @type [Hash<String, Array<String>>]
  results = {}

  Dir.glob("**/config/environments/*.rb").each do |file|
    results[file] = check_file_for_repeated_config_properties(file)
  end

  results.reject! { |_, duplicates| duplicates.empty? }

  results.each do |file, duplicates|
    puts "#{file} has duplicate config properties:"
    duplicates.each { |line| puts "  - #{line}" }
  end

  raise "one or more environment files had duplicate configs" unless results.empty?
end

if __FILE__ == $PROGRAM_NAME
  Dir.chdir(ARGV[0]) do
    ensure_no_duplicate_config_lines_in_environment_files
  end
end
