require "rubygems"

class Builder
  def initialize(config:)
    @config = config
    @rails_cmd_version = build_rails_cmd_version(target_rails_major_minor: config.target_rails_major_minor)
  end

  def build
    Dir.chdir(@config.build_path) do
      delete_any_previous_build
      drop_dbs_from_previous_build

      if @config.vanilla?
        Terminal.puts_header("Building vanilla Rails app")
        system(build_vanilla_cmd_env, build_vanilla_cmd)
      else
        Terminal.puts_header("Building Rails app")
        system(build_cmd_env, build_cmd)
      end
    end
  end

  private

  def base_cmd_parts
    [
      "rails _#{@rails_cmd_version}_ new #{@config.app_name}",
      "-d postgresql",
      "--skip-javascript",
      "--skip-kamal",
      "--skip-solid"
    ]
  end

  def build_rails_cmd_version(target_rails_major_minor:)
    specs = Gem::Specification.find_all_by_name("rails")

    raise "No versions of gem '#{gem_name}' are installed" if specs.empty?

    version = specs
              .map { _1.version.to_s }
              .sort
              .reverse
              .find { |v| v.start_with?(target_rails_major_minor) }
    test_cmd = "rails _#{version}_ -v"
    expected_test_output = "Rails #{version}"
    actual_test_output = `#{test_cmd}`.strip

    raise "Command failed: #{test_cmd}. Actual: #{actual_test_output}" unless expected_test_output == actual_test_output

    Terminal.puts_header("Using Rails version #{version}")

    version
  end

  def delete_any_previous_build
    FileUtils.rm_rf(@config.app_path)
  end

  def build_cmd
    cmd_parts = base_cmd_parts.append("-m #{@config.template_path}")

    puts <<~EO_INFO
      Building command:: #{cmd_parts.inspect}
    EO_INFO

    cmd_parts.join(" ")
  end

  def build_cmd_env
    cmd_env = {
      "TARGET_VERSIONS_PATH" => @config.target_versions_path,
      "CONFIG_PATH" => @config.config_path
    }

    puts <<~EO_INFO
      Building ENV: #{cmd_env.inspect}
    EO_INFO

    cmd_env
  end

  def build_vanilla_cmd_env
    {}
  end

  def build_vanilla_cmd
    puts <<~EO_INFO
      Building command: #{base_cmd_parts.inspect}
    EO_INFO

    base_cmd_parts.join(" ")
  end

  def drop_dbs_from_previous_build
    Terminal.puts_header("Dropping databases from previous build")
    system "psql -c 'DROP DATABASE IF EXISTS #{@config.app_name}_test;'"
    system "psql -c 'DROP DATABASE IF EXISTS #{@config.app_name}_development;'"
    system "psql -c 'DROP DATABASE IF EXISTS #{@config.app_name}_test;'"
  end
end
