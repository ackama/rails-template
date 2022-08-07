puts "=" * 80
puts "Starting variant: deploy_with_capistrano"
puts "=" * 80

append_to_file("Gemfile") do
  <<~'EO_RUBY'

    # Deployment
    #
    # We tell bundler not to require these gems by default because the code that
    # requires them will explicitly require them.
    #
    gem "capistrano", require: false
    gem "capistrano-bundler", require: false
    gem "capistrano-rails", require: false
    gem "capistrano-rbenv", require: false
    gem "capistrano-rake", require: false

    # Capistrano fails when run from Github Action CI unless these gems are
    # present in the bundle. See https://github.com/net-ssh/net-ssh/issues/565
    gem "ed25519", require: false
    gem "bcrypt_pbkdf", require: false

  EO_RUBY
end

run "bundle install"
run "bundle exec cap install"

old_generated_cap_config_snippet = <<~EO_RUBY
  set :application, "my_app_name"
  set :repo_url, "git@example.com:me/my_repo.git"
EO_RUBY

new_ackama_cap_config_snippet = <<~'EO_RUBY'

  ##
  # Uncomment and configure this block if your deployments go through a
  # bastion/jump host.
  #
  # CAP_BASTION_USER = "deploy".freeze
  # CAP_BASTION_HOST = "some-ip-or-hostname".freeze
  # set :ssh_options, {
  #   proxy: Net::SSH::Proxy::Command.new("ssh -o StrictHostKeyChecking=no #{CAP_BASTION_USER}@#{CAP_BASTION_HOST} -W %h:%p")
  # }

  set :application, "TODO_set_app_name"
  set :repo_url, "TODO_set_git_repo_url"

  set :bundle_config, {
    deployment: true,
    without: "development:test"
  }

  # Default value for :linked_files is []
  append :linked_files, ".env"

  # Default value for linked_dirs is []
  append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "storage"

  ##
  # Roles
  #
  # We have a single :app role which contains all the servers we care about in
  # this deployment.
  #
  # We run nginx, rails on the same servers so we do not need the distinction
  # between the :web and :app roles that Capistrano encourages by default.
  #
  # Capistrano is not involved at all in Database management so we don't need a
  # separate :db role either
  #
  set :assets_roles, [:app] # defaults to [:web]
  set :migration_role, :app # defaults to :db

  # Default value for default_env is {}
  set :default_env, path: "$HOME/.rbenv/shims:$HOME/bin:/snap/bin:$PATH"

  set :rbenv_path, "$HOME/.rbenv"
  set :rbenv_ruby, File.read(".ruby-version").strip
  set :rbenv_prefix, "$HOME/.rbenv/bin/rbenv exec"
  set :rbenv_map_bins, %w[rake gem bundle ruby rails]

  namespace :deploy do
    desc "Restart application"
    task :restart do
      on roles(:app), in: :sequence, wait: 5 do
        # TODO: replace these examples with the real commands that control your
        # server
        execute :sudo, "systemctl restart puma"
      end
    end

    task :start do
      on roles(:app) do
        execute :sudo, "systemctl start puma"
      end
    end

    task :stop do
      on roles(:app) do
        execute :sudo, "systemctl stop puma"
      end
    end

    task :status do
      on roles(:app) do
        execute :sudo, "systemctl status puma"
      end
    end

    after :publishing, :restart
  end

EO_RUBY

gsub_file("config/deploy.rb", old_generated_cap_config_snippet, new_ackama_cap_config_snippet)

insert_into_file "Capfile", after: /install_plugin Capistrano::SCM::Git/ do
  <<~'EO_RUBY'
    # Include tasks from other gems included in your Gemfile
    #
    # For documentation on these, see for example:
    #
    #   https://github.com/capistrano/rbenv
    #   https://github.com/capistrano/bundler
    #   https://github.com/capistrano/rails
    #   https://github.com/sheharyarn/capistrano-rake
    #
    require "capistrano/rbenv"
    require "capistrano/bundler"
    require "capistrano/rails/assets"
    require "capistrano/rails/migrations"
    require "capistrano/rake"
  EO_RUBY
end

# Example:
# deploy_envs = {"production"=>"config/deploy/production.rb", "staging"=>"config/deploy/staging.rb"}
deploy_envs = Dir.children("config/deploy")
                 .each_with_object({}) do |file_name, acc|
  key = File.basename(file_name, ".rb")
  acc[key] = "config/deploy/#{file_name}"
end

deploy_envs.each do |env_name, file_path|
  prepend_to_file(file_path) do
    <<~EO_RUBY
      # These are the most common settings required to deploy to a server
      set :rails_env, "#{env_name}"
      set :branch, "#{env_name}"
      set :user, "TODO_your_ssh_user"
      set :deploy_to, "/var/www/TODO_path_to_app_on_server"
      server "TODO.server.example.com", user: "TODO_your_ssh_user", roles: [:app], primary: true

    EO_RUBY
  end
end

cap_tasks_description = `bundle exec cap -T`

# List all available capistrano tasks in output for debugging
puts cap_tasks_description

new_readme_content = <<~EO_CONTENT
  ### Deployment with Capistrano

  This app is configured to deploy with [Capistrano](https://github.com/capistrano/capistrano).
  See `config/deploy.rb` and `config/deploy/` for details.

  The following tasks are available:

  ```
  #{cap_tasks_description}
  ```

EO_CONTENT

append_to_file("README.md", new_readme_content)
