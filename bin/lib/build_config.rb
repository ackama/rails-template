class BuildConfig
  PROJECT_ROOT_PATH = File.absolute_path(File.join(__dir__, "../.."))
  CI_CONFIGS_PATH = File.join(PROJECT_ROOT_PATH, "ci/configs")
  BUILD_PATH = File.join(PROJECT_ROOT_PATH, "tmp/builds")
  TEMPLATE_PATH = File.join(PROJECT_ROOT_PATH, "template.rb")
  TARGET_VERSIONS_PATH = File.join(PROJECT_ROOT_PATH, "target_versions.yml")
  DEFAULT_CONFIG_NAME = "readme_example".freeze
  VANILLA_CONFIG_NAME = "vanilla".freeze
  APP_NAME_SUFFIX = "template_app".freeze
  CI_CONFIGS = Dir.children(CI_CONFIGS_PATH).map { |f| f.sub(".yml", "") }
  AVAILABLE_CONFIG_NAMES = [
    VANILLA_CONFIG_NAME,
    DEFAULT_CONFIG_NAME,
    *CI_CONFIGS
  ].freeze
  TARGET_RAILS_MAJOR_MINOR = YAML.safe_load_file(TARGET_VERSIONS_PATH).fetch("target_rails_major_minor")

  def self.all_configs
    AVAILABLE_CONFIG_NAMES.map { |name| new(name:) }
  end

  ##
  # Resolves the CLI parameter to a list of Config instances
  #
  def self.resolve_to_configs(cli_param)
    return all_configs if cli_param == "all_variants"
    return [new(name: cli_param)] if AVAILABLE_CONFIG_NAMES.include?(cli_param)

    [new(name: DEFAULT_CONFIG_NAME)]
  end

  attr_reader :name, :app_name, :config_path

  def initialize(name:)
    @name = name
    @app_name = case name
                when VANILLA_CONFIG_NAME
                  "#{name}_#{target_rails_major}_#{APP_NAME_SUFFIX}"
                else
                  "#{name}_#{APP_NAME_SUFFIX}"
                end

    @config_path = case name
                   when DEFAULT_CONFIG_NAME
                     File.join(PROJECT_ROOT_PATH, "ackama_rails_template.config.yml")
                   when VANILLA_CONFIG_NAME
                     nil
                   else
                     File.join(CI_CONFIGS_PATH, "#{name}.yml")
                   end
  end

  def vanilla?
    name == VANILLA_CONFIG_NAME
  end

  def app_path
    File.join(BUILD_PATH, app_name)
  end

  def target_versions_path
    TARGET_VERSIONS_PATH
  end

  def build_path
    BUILD_PATH
  end

  def template_path
    return nil if vanilla?

    TEMPLATE_PATH
  end

  def inspect
    <<~INSPECT
      <Config:
        @name: #{name}
        @app_name: #{app_name}
        @config_path: #{config_path}
        @app_path: #{app_path}
        @target_versions_path: #{target_versions_path}
        @build_path: #{build_path}
        @template_path: #{template_path}
      >
    INSPECT
  end

  def target_rails_major_minor
    TARGET_RAILS_MAJOR_MINOR
  end

  def target_rails_major
    TARGET_RAILS_MAJOR_MINOR.split(".").first
  end
end
