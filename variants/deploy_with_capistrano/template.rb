TERMINAL.puts_header "Starting variant: deploy_with_capistrano"

append_to_file("Gemfile") do
  <<~EO_RUBY

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

new_ackama_cap_config_snippet = <<~EO_RUBY

  ##
  # Uncomment and configure this block if your deployments go through a
  # bastion/jump host.
  #
  # CAP_BASTION_USER = "deploy".freeze
  # CAP_BASTION_HOST = "some-ip-or-hostname".freeze
  # set :ssh_options, {
  #   proxy: Net::SSH::Proxy::Command.new("ssh -o StrictHostKeyChecking=no \#{CAP_BASTION_USER}@\#{CAP_BASTION_HOST} -W %h:%p")
  # }

  set :application, "TODO_set_app_name"
  set :repo_url, "#{TEMPLATE_CONFIG.git_repo_url.presence || "TODO_set_git_repo_url"}"
  set :git_shallow_clone, 1

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
  # set :rbenv_type, :user # or :system, or :fullstaq (for Fullstaq Ruby), depends on your rbenv setup
  set :rbenv_ruby, File.read(".ruby-version").strip
  set :rbenv_prefix, "$HOME/.rbenv/bin/rbenv exec"
  set :rbenv_map_bins, %w[rake gem bundle ruby rails]

  namespace :git do
    desc "Determine the commit time of the revision that will be deployed"
    task :set_current_revision_time do
      on release_roles(:all), in: :groups, limit: fetch(:git_max_concurrent_connections), wait: fetch(:git_wait_interval) do
        within repo_path do
          with fetch(:git_environmental_variables) do
            # fetches the revision time of the latest commit for the environment branch as a unix timestamp
            set :current_revision_time, capture(:git, "log -1 --pretty=format:\\"%ct\\" #\{fetch(:branch)}")
          end
        end
      end
    end
  end

  namespace :deploy do
    desc "Restart application"
    task :restart do
      on roles(:app), in: :sequence, wait: 5 do
        execute :sudo, "systemctl restart puma"
        #{TEMPLATE_CONFIG.apply_variant_sidekiq? ? 'execute :sudo, "systemctl restart sidekiq"' : ""}
      end
    end

    task :start do
      on roles(:app) do
        execute :sudo, "systemctl start puma"
        #{TEMPLATE_CONFIG.apply_variant_sidekiq? ? 'execute :sudo, "systemctl start sidekiq"' : ""}
      end
    end

    task :stop do
      on roles(:app) do
        execute :sudo, "systemctl stop puma"
        #{TEMPLATE_CONFIG.apply_variant_sidekiq? ? 'execute :sudo, "systemctl stop sidekiq"' : ""}
      end
    end

    task :status do
      on roles(:app) do
        execute :sudo, "systemctl status puma"
        #{TEMPLATE_CONFIG.apply_variant_sidekiq? ? 'execute :sudo, "systemctl status sidekiq"' : ""}
      end
    end

    after :publishing, :restart

    desc "Place a REVISION_TIME file with the current revision commit time in the current release path"
    task set_current_revision_time: "git:set_current_revision_time" do
      on release_roles(:all) do
        within release_path do
          execute :echo, ""#\{fetch(:current_revision_time)}" > REVISION_TIME"
        end
      end
    end

    task :set_previous_revision_time do
      on release_roles(:all) do
        target = release_path.join("REVISION_TIME")
        set(:previous_revision_time, capture(:cat, target, "2>/dev/null")) if test "[ -f #\{target} ]"
      end
    end

    after :set_current_revision, :set_current_revision_time
    after :set_previous_revision, :set_previous_revision_time
  end

  namespace :debug do
    desc "Check Capistrano's connection to the servers"
    task :check_connection do
      on roles(:app) do
        execute "whoami"
        execute "hostname"
      end
    end

    desc "Check the current revision hash and commit time being run on each server"
    task check_revision: ["git:set_current_revision", "git:set_current_revision_time"] do
      on roles(:app) do
        hash = fetch(:current_revision)
        time = Time.at(fetch(:current_revision_time).to_i).utc
        info "#\{host}: running revision #\{hash}, committed at #\{time}"
      end
    end
  end

EO_RUBY

gsub_file("config/deploy.rb", old_generated_cap_config_snippet, new_ackama_cap_config_snippet)

insert_into_file "Capfile", after: /install_plugin Capistrano::SCM::Git/ do
  <<~EO_RUBY
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
  likely_branch_name = case env_name
                       when "staging"
                         "main"
                       when "production"
                         "production"
                       else
                         "TODO_branch_name"
                       end

  prepend_to_file(file_path) do
    <<~EO_RUBY
      # These are the most common settings required to deploy to a server
      set :rails_env, "#{env_name}"
      set :branch, "#{likely_branch_name}"
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
