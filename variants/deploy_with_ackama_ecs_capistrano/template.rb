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
