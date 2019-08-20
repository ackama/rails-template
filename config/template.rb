apply "config/application.rb"
template "config/database.example.yml.tt"
template "config/secrets.example.yml"
remove_file "config/database.yml"
remove_file "config/spring.rb"
copy_file "config/puma.rb", force: true
remove_file "config/secrets.yml"
copy_file "config/sidekiq.yml"

gsub_file "config/routes.rb", /  # root 'welcome#index'/ do
  '  root "home#index"'
end

copy_file "config/initializers/generators.rb"
copy_file "config/initializers/rotate_log.rb"
copy_file "config/initializers/version.rb"

gsub_file "config/initializers/filter_parameter_logging.rb", /\[:password\]/ do
  "%w[password secret session cookie csrf]"
end

apply "config/environments/development.rb"
apply "config/environments/production.rb"
apply "config/environments/test.rb"
template "config/environments/staging.rb.tt"

route 'root "home#index"'
route %Q(mount Sidekiq::Web => "/sidekiq" # monitoring console\n)
route "require 'sidekiq/web'"
