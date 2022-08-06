puts "TEMP" * 10
puts "SETTING UP ACKAMA EC2 CAPISTRANO"
puts "TEMP" * 10

# add required gems and run bundle install

# append to Gemfile

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

    # these are quite specific to how Ackama deploys on EC2
    gem "capistrano-rake", require: false
    gem "capistrano-locally", require: false

    # Capistrano fails when run from Github Action CI unless these gems are
    # present in the bundle. See https://github.com/net-ssh/net-ssh/issues/565
    gem "ed25519", require: false
    gem "bcrypt_pbkdf", require: false

  EO_RUBY
end

run "bundle install"
run "bundle exec cap install"

insert_into_file "Capfile", after: /install_plugin Capistrano::SCM::Git/ do
  <<~'EO_RUBY'
    # Include tasks from other gems included in your Gemfile
    #
    # For documentation on these, see for example:
    #
    #   https://github.com/capistrano/rbenv
    #   https://github.com/capistrano/bundler
    #   https://github.com/capistrano/rails
    #
    require "capistrano/rbenv"
    require "capistrano/bundler"
    require "capistrano/rails/assets"
    require "capistrano/rails/migrations"
    require "capistrano/rake"
    require "capistrano/locally"
  EO_RUBY
end

# List all available capistrano tasks in output for debugging
run "bundle exec cap -T"
