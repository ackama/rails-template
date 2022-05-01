source_paths.unshift(File.dirname(__FILE__))

puts "Adding pundit to Gemfile"

gem "pundit"

run "bundle install"
run "rails g pundit:install"
run "rails g pundit:policy example"

copy_file "spec/policies/example_policy_spec.rb", force: true
copy_file "spec/policies/application_policy_spec.rb", force: true

# Configure app/controllers/application_controller.rb
insert_into_file "app/controllers/application_controller.rb",
                 after: /^class ApplicationController < ActionController::Base\n/ do
  <<-RUBY
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index
  RUBY
end

insert_into_file "app/controllers/application_controller.rb", before: /^end/ do
  <<-RUBY

  private

  def user_not_authorized
    flash[:alert] = I18n.t("authorization.not_authorized")
    redirect_to(request.referer || root_path)
  end
  RUBY
end

insert_into_file "config/locales/en.yml", after: /^en:\n/ do
  <<-YAML
  authorization:
    not_authorized: "You are not authorised to perform this action."
  YAML
end

insert_into_file "spec/rails_helper.rb", after: %r{require "axe/rspec"\n} do
  <<~REQUIRE
    require "pundit/rspec"
  REQUIRE
end

insert_into_file "app/controllers/home_controller.rb", after: %r{def index\n} do
  <<-RUBY
    # tell pundit that we are ok with not having authorization on this endpoint
    skip_policy_scope
  RUBY
end