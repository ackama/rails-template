##
# Invokes the template as a user would, not as CI does via the build-and-test script.
# Automatically removes old DB before generating the app if required
#
class Builder
  def initialize(config:)
    @config = config
  end

  def build
    verify_rails_cmd_is_expected_version!

    Dir.chdir(@config.build_path) do
      delete_any_previous_build
      drop_dbs_from_previous_build

      # TODO: how to handle errors? raise? or log and continue? or rename the app dir with a .failed suffix?
      # TODO: how to handle output? redirect to a file? or sep files for stdout and stderr?

      if @config.vanilla?
        system(build_vanilla_cmd_env, build_vanilla_cmd)
      else
        system(build_cmd_env, build_cmd)
      end
    end
  end

  private

  def base_cmd_parts
    [
      "rails new #{@config.app_name}",
      "-d postgresql",
      "--skip-javascript",
      "--skip-kamal",
      "--skip-solid"
    ]
  end

  def verify_rails_cmd_is_expected_version!
    actual_rails_version = `rails -v`.strip.sub("Rails ", "")

    return if actual_rails_version.start_with?(@config.target_rails_major_minor)

    raise "Expected Rails version #{@config.target_rails_major_minor}, but got #{actual_rails_version}"
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

  def print_separator
    puts ""
    puts "*" * 80
    puts ""
  end

  def drop_dbs_from_previous_build
    print_separator
    system "psql -c 'DROP DATABASE IF EXISTS #{@config.app_name}_test;'"
    system "psql -c 'DROP DATABASE IF EXISTS #{@config.app_name}_development;'"
    system "psql -c 'DROP DATABASE IF EXISTS #{@config.app_name}_test;'"
    print_separator
  end
end
