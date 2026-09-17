#!/usr/bin/env ruby

require "yaml"

class SortRubocopConfig
  # @param [String] config_file_path
  def self.run(config_file_path, default_config)
    new(config_file_path, default_config).sort!
  end

  # @param [String] config_file_path
  def initialize(config_file_path, default_config)
    # @type [String]
    @config_file_path = config_file_path

    @default_config = default_config

    # @type [Hash]
    @sections = {}

    parse_sections

    add_unconfigured_cops_changing_in_v2

    # apply_v2_changes_except_disables
  end

  def sort!
    sorted_sections = @sections.sort_by do |k, _|
      [
        # document start marker
        k == "---\n" ? -1 : 0,
        # plugins list
        k == "plugins:\n" ? -1 : 0,
        # base config properties (i.e "inherit_gem")
        k[0].downcase == k[0] ? -1 : 0,
        # everything else without colons or newlines so that plugin config will be
        # put before cop config, since colons are alphabetically smaller than slashes
        k.sub(/:\s*\z/, "")
      ]
    end

    joined = sorted_sections.map { |_, lines| lines.join }.join("\n")

    # make sure there isn't a blank line after the start marker to keep prettier happy
    File.write(@config_file_path, joined.gsub("---\n\n", "---\n"))
  end

  private

  def parse_sections
    section_name = ""
    section_lines = []

    File.readlines(@config_file_path).each do |line|
      # skip empty lines entirely
      next if line.strip.empty?

      # if the line does not start with a space, the previous section (if there
      # is one) must have finished since YAML is indentation based
      unless line.start_with?(" ")
        unless section_name.empty?
          add_section(section_name, section_lines)

          section_name = ""
          section_lines = []
        end

        # if the line is not a comment, it must be the start of the section
        unless line.start_with?("#")
          section_name = line

          puts "found section #{section_name}"
        end
      end

      section_lines << line
    end

    # add the last section we were parsing
    add_section(section_name, section_lines) unless section_name.empty?
  end

  # @param [String] name
  # @param [Array<String>] lines
  def add_section(name, lines)
    raise "duplicate section #{name}" if @sections.key?(name)

    lines = annotate_v2_changes(name, lines)

    @sections[name] = lines
  end

  # @param [String] name
  # @param [Array<String>] lines
  #
  # @return [Array<String>]
  def annotate_v2_changes(name, lines)
    name = name.delete_suffix(":\n")
    return lines unless @default_config.key?(name)

    config = @default_config[name]

    # ensure each option with a change being previewed is set explicitly,
    # with the previewed value being captured in a comment for review
    config["Preview"].each do |option, new_default|
      lines = annotate_v2_change(lines, option, config[option], new_default)
    end

    lines
  end

  def annotate_v2_change(lines, option, current_default, new_default)
    annotation = "# TODO: will be changed in v2 to '#{new_default}'"

    found = false

    # if the option is already being configured, annotate it with a comment...
    lines = lines.flat_map do |line|
      if line.strip.start_with?("#{option}: ")
        # add the annotation if it's not already present
        unless line.end_with?("#{annotation}\n") || line.include?("# TODO: was changed in v2 from '")
          line = "#{line.rstrip} #{annotation}\n"
        end
        found = true
      end

      [line]
    end

    # ...otherwise, add it with the current default value along with the annotation comment
    lines << "  #{option}: #{current_default} #{annotation}\n" unless found

    lines
  end

  def add_unconfigured_cops_changing_in_v2
    @default_config.each do |name, config|
      next if @sections.key?("#{name}:\n") || name == "AllCops"

      @sections["#{name}:\n"] = ["#{name}:\n"] + config["Preview"].map do |option, value|
        ["  #{option}: #{config[option]} # TODO: will be changed in v2 to '#{value}'\n"]
      end
    end
  end

  def apply_v2_changes_except_disables
    @sections.each_key do |name|
      @sections[name] = @sections[name].map do |line|
        # don't apply disables as existing code will already be compliant
        next line if line == "  Enabled: true # TODO: will be changed in v2 to 'false'\n"

        matched = line.match(/ {2}(\w+): (\w+) # TODO: will be changed in v2 to '(\w+)'/)

        next line if matched.nil?

        line
          .gsub("#{matched[1]}: #{matched[2]}", "#{matched[1]}: #{matched[3]}")
          .gsub("# TODO: will be changed in v2 to '#{matched[3]}'", "# TODO: was changed in v2 from '#{matched[2]}'")
      end
    end
  end
end

# download this from https://raw.githubusercontent.com/rubocop/rubocop/refs/heads/master/config/default.yml
default_config = YAML.unsafe_load_file(".rubocop.default.yml").select do |key, value|
  key != "AllCops" && value.key?("Preview")
end

SortRubocopConfig.run(ARGV[0] || "./.rubocop.yml", default_config)
