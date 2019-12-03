apply "config/application.rb"
template "config/database.example.yml.tt"
template "config/secrets.example.yml"
remove_file "config/database.yml"
remove_file "config/spring.rb"
copy_file "config/puma.rb", force: true
remove_file "config/secrets.yml"
copy_file "config/sidekiq.yml"


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

route <<-EO_ROUTES
  ##
  # Workaround a "bug" in lighthouse CLI
  #
  # Lighthouse CLI (versions 5.4 - 5.6 tested) issues a `GET /asset-manifest.json`
  # request during its run - the URL seems to be hard-coded. This file does not
  # exist so, during tests, your test will fail because rails will die with a 404.
  #
  # Lighthouse run from Chrome Dev-tools does not have the same behaviour.
  #
  # This hack works around this. This behaviour might be fixed by the time you
  # read this. You can check by commenting out this block and running the
  # accessibility and performance tests. You are encouraged to remove this hack
  # as soon as it is no longer needed.
  #
  if defined?(Webpacker) && Rails.env.test?
    # manifest paths depend on your webpacker config so we inspect it
    manifest_path = Webpacker::Configuration
      .new(root_path: Rails.root, config_path: Rails.root.join("config/webpacker.yml"), env: Rails.env)
      .public_manifest_path
      .relative_path_from(Rails.root.join("public"))
      .to_s
    get "/asset-manifest.json", to: redirect(manifest_path)
  end

  ##
  # If you want the Sidekiq web console in production environments you need to
  # put it behind some authentication first.
  #
  if defined?(Sidekiq::Web) && Rails.env.development?
    mount Sidekiq::Web => "/sidekiq" # Sidekiq monitoring console
    require "sidekiq/web"
  end

  root "home#index"
EO_ROUTES
