source_paths.unshift(File.dirname(__FILE__))

puts "Adding pundit to Gemfile"

gem "pundit"

run "bundle install"
run "rails g pundit:install"
run "rails g pundit:policy example"

copy_file "spec/policies/example_policy_spec.rb", force: true

# Configure app/controllers/application_controller.rb
insert_into_file "app/controllers/application_controller.rb",
                 after: /^class ApplicationController < ActionController::Base\n/ do
  <<~RUBY
    include Pundit

    after_action :verify_authorized, except: %i[index], unless: :skip_verify_authorized?
    after_action :verify_policy_scoped, only: :index, unless: :skip_verify_policy_scoped?
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  RUBY
end

insert_into_file "app/controllers/application_controller.rb", before: /^end/ do
  <<~RUBY
    private

    def skip_verify_authorized?
      current_devise_controller?
    end

    def skip_verify_policy_scoped?
      is_a?(::HomeController) || current_devise_controller?
    end

    def current_devise_controller?
      return false unless respond_to?(:devise_controller?)

      devise_controller?
    end

    def user_not_authorized
      flash[:alert] = I18n.t("authorization.not_authorized")
      redirect_to(request.referer || root_path)
    end
  RUBY
end

apply "spec/rails_helper.rb"
apply "config/locales/en.yml.rb"
