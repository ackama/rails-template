TERMINAL.puts_header "Starting variant: deploy_with_ackama_ecs_capistrano"

append_to_file!("Gemfile") do
  <<~EO_RUBY

    # Deployment
    #
    # We tell bundler not to require these gems by default because the code that
    # requires them will explicitly require them.
    #
    gem "aws-sdk-ecr", require: false
    gem "aws-sdk-elasticloadbalancingv2", require: false
    gem "aws-sdk-sts", require: false
    gem "capistrano", "~> 3.20", require: false
    gem "ecs_deploy", require: false

  EO_RUBY
end

run "bundle install"

# replace the development-focused docker setup from backend-base with a
# production image for ECS, and a docker-compose.yml just for local services
template "variants/deploy_with_ackama_ecs_capistrano/Dockerfile.tt", "Dockerfile", force: true
copy_file "variants/deploy_with_ackama_ecs_capistrano/dockerignore", ".dockerignore", force: true
template "variants/deploy_with_ackama_ecs_capistrano/docker-compose.yml.tt", "docker-compose.yml", force: true
copy_file "variants/deploy_with_ackama_ecs_capistrano/bin/docker-entrypoint", "bin/docker-entrypoint", force: true
chmod "bin/docker-entrypoint", "+x"

copy_file "variants/deploy_with_ackama_ecs_capistrano/Capfile", "Capfile"
template "variants/deploy_with_ackama_ecs_capistrano/config/deploy.rb.tt", "config/deploy.rb"
copy_file "variants/deploy_with_ackama_ecs_capistrano/config/deploy_tasks.rb", "config/deploy_tasks.rb"

%w[staging production].each do |env_name|
  template "variants/deploy_with_ackama_ecs_capistrano/config/deploy/stage.rb.tt", "config/deploy/#{env_name}.rb"
end

gsub_file!(
  "README.md",
  <<~OLD,
    ## Secrets

    All credentials and the `.env` file for this project are stored in Ackama 1Password vault named `TODO`

        TODO: Ensure that all secrets in this app are stored **only** in Ackama 1Password

    ## Healthchecks
  OLD
  <<~NEW)
    ## Secrets

    Application secrets are stored as JSON in an AWS Secrets Manager item per
    environment. Each key in the JSON object represents one environment variable
    consumed by the Rails app and mapped into the ECS task definition.

    The set of mapped keys is derived from the `example.env` file during the
    deployment process.

    > [!WARNING]
    >
    > Because secrets are resolved by ECS as part of deployment, all referenced keys
    > must already exist in the Secrets Manager JSON before a new deployment is
    > started.
    >
    > If a key is missing, ECS will fail the task definition update and the
    > deployment will error.
    >
    > Keys may have blank values, but they must be present. As a result, optional
    > variables should be checked for blank values rather than `nil`, and defaults
    > should be applied using `ENV["VAR"].presence` rather than `ENV.fetch`.
  NEW
