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

    after_action :verify_authorized, except: %i[index], unless: :current_devise_controller?
    after_action :verify_policy_scoped, only: :index, unless: :skip_policy_scoped_controller?
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  RUBY
end

insert_into_file "app/controllers/application_controller.rb", before: /^end/ do
  <<~RUBY
    private
  
    def skip_policy_scoped_controller?
      is_a?(::HomeController) || current_devise_controller?
    end
  
    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to(request.referer || root_path)
    end
  
    def current_devise_controller?
      devise_controller?
    rescue NoMethodError
      false
    end
  RUBY
end

apply "spec/rails_helper.rb"
