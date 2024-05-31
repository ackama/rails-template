source_paths.unshift(File.dirname(__FILE__))

TERMINAL.puts_header "Adding pundit to Gemfile"

gem "pundit"

run "bundle install"
run "rails g pundit:install"
run "rails g pundit:policy example"

# Pundit uses NoMethodError which is easier to catch as it extends from StandardError,
# but it's technically not correct as our class does respond to the method in question
#
# For now, we're just going to stick with the more traditional error for this situation
gsub_file! "app/policies/application_policy.rb", "raise NoMethodError", "raise NotImplementedError"

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
    # This application uses the Rails default of increasing numeric IDs for
    # records in the database.
    #
    # This means there are security implications to how you inform a user that
    # they are not authorized. If this app returns a different error message
    # depending on whether the resource exists or not, then a (potentially
    # malicious) user could use the different error messages to discover how
    # many instances of a model exist in the database. Depending on the context,
    # this could be a serious security issue e.g.
    #
    # * a competitor could find out how many users have signed up
    # * an attacker could guess what the next user ID would be which might be
    #   useful to them in another context
    #
    # This template defaults to the more secure (but less user-friendly) option
    # of making Pundit authorization errors look like
    # ActiveRecord::RecordNotFound errors (returning the standard Rails 404
    # page). You may choose to use the more user-friendly version in your
    # application but be aware of the security consequences and that the team
    # will almost certainly have to defend the choice in a penetration test.

    # The more secure but less user-friendly option (our default):
    # ############################################################
    raise ActiveRecord::RecordNotFound

    # The user-friendly but less secure option:
    # #########################################
    # flash[:alert] = I18n.t("authorization.not_authorized")
    # redirect_to(request.referer || root_path)
  end
  RUBY
end

insert_into_file "config/locales/en.yml", after: /^en:\n/ do
  <<-YAML
  authorization:
    not_authorized: 'You are not authorised to perform this action.'
  YAML
end

insert_into_file "spec/rails_helper.rb", after: %r{require "axe/rspec"\n} do
  <<~REQUIRE
    require "pundit/rspec"
  REQUIRE
end

insert_into_file "app/controllers/home_controller.rb", after: /def index\n/ do
  <<-RUBY
    # tell pundit that we are ok with not having authorization on this endpoint
    skip_policy_scope
  RUBY
end
