class ComparisonConfig
  PROJECT_ROOT_PATH = File.absolute_path(File.join(__dir__, "../.."))
  BUILD_PATH = File.join(PROJECT_ROOT_PATH, "tmp/builds")

  class << self
    def build_path
      BUILD_PATH
    end

    def comparison_repo_root_path
      File.join(PROJECT_ROOT_PATH, "tmp/rails-template-variants-comparison")
    end

    def vanilla_build_name
      all_builds.find { |build_name| build_name.start_with?("vanilla_") }
    end

    def vanilla_build_path
      File.join(BUILD_PATH, vanilla_build_name)
    end

    def comparison_builds
      all_builds - [vanilla_build_name]
    end

    def all_builds
      Dir.children(BUILD_PATH)
    end
  end
end
