# flush output immediately, as Ruby otherwise buffers it when not attached to
# a terminal (e.g. in CI), which delays logs from long-running commands
$stdout.sync = true

set :aws_account_id, lambda {
  require "aws-sdk-sts"

  c = Aws::STS::Client.new(region: fetch(:aws_region))
  c.get_caller_identity.account
}

set :ecr_url, -> { "#{fetch(:aws_account_id)}.dkr.ecr.#{fetch(:aws_region)}.amazonaws.com" }
set :ecr_repository_url, -> { "#{fetch(:ecr_url)}/#{fetch(:name_prefix_kebab_case)}" }

def ecs_role_arn(suffix)
  "arn:aws:iam::#{fetch(:aws_account_id)}:role/#{fetch(:name_prefix_pascal_case)}#{suffix}"
end

def run_please(*cmd, match: nil, stdin_data: nil)
  require "open3"

  matched_value = ""

  Open3.popen2e(*cmd) do |stdin, stdout_and_stderr, wait_thr|
    stdin.write(stdin_data) unless stdin_data.nil?
    stdin.close

    stdout_and_stderr.each do |line|
      puts line

      matched_value = Regexp.last_match(1) if !match.nil? && line.match(match)
    end

    exit_status = wait_thr.value.exitstatus
    raise StandardError, "\"#{cmd.join(" ")}\" exited with non-zero code #{exit_status}" if exit_status != 0
  end

  matched_value
end

# @param [String] secret_name
# @param [Array<String>] variable_names
def map_secrets(secret_name, variable_names)
  arn = "arn:aws:secretsmanager:#{fetch(:aws_region)}:#{fetch(:aws_account_id)}:secret:#{fetch(:name_prefix_secret_case)}/#{secret_name}"

  variable_names.map { |name| { name:, value_from: "#{arn}:#{name}::" } }
end

namespace :ecs do
  task :build do
    image_ref = ENV.fetch("ECS_DOCKER_IMAGE_REF", nil)

    if image_ref.nil?
      require "tmpdir"

      Dir.mktmpdir do |dir|
        iidfile_file = File.join(dir, "iidfile")

        # Fargate tasks default to X86_64, so build for that regardless of the host's architecture
        run_please("docker", "build", "--platform", "linux/amd64", "--iidfile=#{iidfile_file}", ".")

        image_ref = File.read(iidfile_file)
      end

      puts "successfully built image #{image_ref}"
    else
      puts "using pre-built image #{image_ref}"
    end

    raise "could not determine image ref" if image_ref.nil? || image_ref.empty? # rubocop:disable Rails/Blank

    set :image_ref, image_ref
  end

  task push: [:build] do
    require "aws-sdk-ecr"

    token = Aws::ECR::Client.new(region: fetch(:aws_region)).get_authorization_token.authorization_data.first.authorization_token
    run_please("docker", "login", "--username", "AWS", "--password-stdin", fetch(:ecr_url), stdin_data: token.unpack1("m").delete_prefix("AWS:"))

    puts "successfully logged docker in to ecr"

    image_ref = fetch(:image_ref)
    image_registry = fetch(:ecr_repository_url)

    run_please("docker", "tag", image_ref, image_registry)

    puts "successfully tagged docker image #{image_ref} as #{image_registry}"

    image_digest = run_please("docker", "push", image_registry, match: /digest: (sha256:[0-9a-f]+) size:/)

    raise "could not determine digest of pushed image" if image_digest.empty?

    puts "successfully pushed #{image_ref} to #{image_registry} (digest: #{image_digest})"
    set :image_digest, image_digest
  end

  before :register_task_definition, :push do
    set :image_ref_with_registry, "#{fetch(:ecr_repository_url)}@#{fetch(:image_digest)}"

    puts "deploying #{fetch(:image_ref_with_registry)}"
  end
end
