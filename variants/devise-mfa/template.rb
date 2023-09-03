# Allow us to copy file with root at the directory this file is in
source_paths.unshift(File.dirname(__FILE__))

######################################
# Gemfile
######################################

TERMINAL.puts_header "Adding devise-two-factor, rqrcode-rails3 to Gemfile"
run "bundle add devise-two-factor"
run "bundle add rqrcode-rails3"

######################################
# Migration
######################################

# We need devise-two-factor but we aren't using it in the standard way so we
# don't run it's generator. Instead we install it manually.
TERMINAL.puts_header "Adding devise-two-factor manually"

raw_output = `bundle exec rails g migration AddOtpSecretsToUser --pretend`
migration_path = raw_output.lines.find { |line| line.match?(%r{create\s+db/migrate}) }.split.last
create_file(migration_path) do
  <<~EO_RUBY
    class AddOtpSecretsToUser < ActiveRecord::Migration[7.0]
      def change
        change_table :users, bulk: true do |t|
          t.string :otp_secret
          t.integer :consumed_timestep
          t.boolean :otp_required_for_login, default: false, null: false
        end
      end
    end
  EO_RUBY
end

run "bundle exec rails db:migrate"

######################################
# User model
######################################

TERMINAL.puts_header "Configuring user model"
insert_into_file("app/models/user.rb", after: /^class User.*?\n/) do
  <<-EO_RUBY
  # NOTE: devise-two-factor requests that database_authenticatable is replaced
  # with two_factor_authenticatable. We do NOT do this, because we have a
  # two-step authentication process. We use DatabaseAuthenticatable to validate
  # the email and password, and then validate the OTP code or backup code in a
  # second step. The same is true of two_factor_backupable. Including this
  # strategy means that a failed auth attempt is flagged as a failed attempt,
  # even when rendering the MFA validation page. We DO include the model
  # methods, because we still use them
  #
  include Devise::Models::TwoFactorAuthenticatable
  include Devise::Models::TwoFactorBackupable

  EO_RUBY
end

insert_into_file("app/models/user.rb", before: /^end/) do
  <<-EO_RUBY

  def enable_otp!
    update!(otp_secret: User.generate_otp_secret)
  end

  # this resets the secret but deliberately does not touch the
  # `otp_required_for_login` flag
  def reset_otp_secret!
    update!(otp_secret: User.generate_otp_secret)
  end

  def require_otp!
    update!(otp_required_for_login: true)
  end

  def otp_enabled_and_required?
    otp_secret.present? && otp_required_for_login
  end

  def disable_otp!
    update!(otp_secret: nil, otp_required_for_login: false, otp_backup_codes: nil)
  end

  def discard_otp_secret!
    update!(otp_secret: nil)
  end
  EO_RUBY
end

######################################
# Controllers
######################################

TERMINAL.puts_header "Configuring MFA controllers"

copy_file "variants/devise-mfa/app/controllers/users/devise_controller.rb", "app/controllers/users/devise_controller.rb"
copy_file "variants/devise-mfa/app/controllers/users/sessions_controller.rb", "app/controllers/users/sessions_controller.rb", force: true
copy_file "variants/devise-mfa/app/controllers/users/multi_factor_authentications_controller.rb", "app/controllers/users/multi_factor_authentications_controller.rb"
copy_file "variants/devise-mfa/app/controllers/dashboards_controller.rb", "app/controllers/dashboards_controller.rb"

# TODO: include this "force MFA" code or not? if we include it, readme doc needs to be updated
gsub_file("app/controllers/application_controller.rb", /^\s*private$/) do
  <<-EO_RUBY

  # Controller actions which inherit from this controller default to requiring
  # the user to have MFA enabled. Note that this does not also check they are
  # authenticated - that check is performed by the usual devise
  #
  #     before_action :authenticate_user!
  #
  # before_action :require_multi_factor_authentication!

  private

  ##
  # When this method is run as a before_action, it will prevent the user from
  # running controller actions until they have set up MFA.
  #
  # def require_multi_factor_authentication!
  #   return unless user_signed_in?
  #   return if devise_controller?
  #   return if current_user.otp_required_for_login?
  #
  #   redirect_to new_users_multi_factor_authentication_path,
  #     alert: t("application.multi_factor_authentication_required")
  # end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || dashboards_path
  end
  EO_RUBY
end

######################################
# Secrets
######################################

# TODO: figure out whatl if anything I need to change in our current way of managing secrets

# insert_into_file("config/secrets.yml", after: /\A.+secret_key_base.+\z/) doVjjjjjjjjj
#   <<-EO_LINE
#     devise_two_factor_secret_encryption_key: "<%= ENV['DEVISE_TWO_FACTOR_SECRET_ENCRYPTION_KEY'] %>"
#   EO_LINE
# end

# append_to_file ".env" do
#   <<~EO_LINE

#     # Use 'bundle exec rails secret' to generate a real value here
#     DEVISE_TWO_FACTOR_SECRET_ENCRYPTION_KEY=fortheloveofallyouholddeardonotusethissecretinproduction
#   EO_LINE
# end

######################################
# Views
######################################

TERMINAL.puts_header "Copying views"
copy_file "variants/devise-mfa/app/views/users/sessions/mfa_prompt.html.erb", "app/views/users/sessions/mfa_prompt.html.erb"
copy_file "variants/devise-mfa/app/views/dashboards/show.html.erb", "app/views/dashboards/show.html.erb"
copy_file "variants/devise-mfa/app/views/application/_mfa_help.html.erb", "app/views/application/_mfa_help.html.erb"
copy_file "variants/devise-mfa/app/views/application/_header.html.erb", "app/views/application/_header.html.erb", force: true
directory "variants/devise-mfa/app/views/users/multi_factor_authentications", "app/views/users/multi_factor_authentications"

insert_into_file("app/views/users/registrations/edit.html.erb", before: %r{^<h3>Cancel my account</h3>}) do
  <<~EO_FIELD

    <h2 class="">Two-factor authentication</h2>
    <p class="">Manage the device and codes you’ll use to sign in to this application.</p>
    <%= link_to "Manage my two-factor authentication", users_multi_factor_authentication_path %>
    <%= render "application/mfa_help" %>

  EO_FIELD
end

######################################
# Config
######################################

TERMINAL.puts_header "Adding otp_attempt to filtered params in logs"
append_to_file("config/initializers/filter_parameter_logging.rb") do
  <<~EO_CONTENT
    Rails.application.config.filter_parameters += %i[otp_attempt]
  EO_CONTENT
end

TERMINAL.puts_header "Tweaking config/initializers/devise.rb"

gsub_file "config/initializers/devise.rb",
          "  # config.sign_in_after_reset_password = true",
          <<-EO_CONFIG
  #
  # This must be set to false when using devise-two-factor - see
  # https://github.com/tinfoil/devise-two-factor#disabling-automatic-login-after-password-resets
  config.sign_in_after_reset_password = false
          EO_CONFIG

gsub_file "config/initializers/devise.rb",
          "  # config.parent_controller = 'DeviseController'",
          '  config.parent_controller = "Users::DeviseController"'

######################################
# Images
######################################

TERMINAL.puts_header "Copying MFA logos"
directory "variants/devise-mfa/app/frontend/images/mfa", "app/frontend/images/mfa"

######################################
# Routes
######################################

TERMINAL.puts_header "Setting up routes.rb"
insert_into_file("config/routes.rb", before: /^end/) do
  <<-EO_ROUTES

  namespace :users do
    devise_scope :user do
      post :validate_otp, to: "sessions#validate_otp"
    end

    resource :multi_factor_authentication, only: %i[new show create] do
      post :backup_codes, action: :create_backup_codes
      delete :backup_codes, action: :destroy_backup_codes
    end
  end

  resource :dashboards, only: [:show]
  EO_ROUTES
end

######################################
# Pundit
######################################

# TODO

######################################
# Locales
######################################

TERMINAL.puts_header "Setting up locales"
copy_file "variants/devise-mfa/config/locales/mfa.en.yml", "config/locales/mfa.en.yml"

######################################
# Documentation
######################################

TERMINAL.puts_header "Copying MFA docs"
copy_file "variants/devise-mfa/doc/multi_factor_authentication_sequence.png", "doc/multi_factor_authentication_sequence.png"
copy_file "variants/devise-mfa/doc/multi_factor_authentication.md", "doc/multi_factor_authentication.md"
remove_file "doc/.keep"

######################################
# Clean up
######################################

TERMINAL.puts_header "Running rubocop to clean up generated files"
run "bundle exec rubocop -A"

TERMINAL.puts_header "Commiting changes to git"
git add: "-A ."
git commit: "-n -m 'Install and configure devise with MFA enabled'"

# TODO: remove this before merge!
# TERMINAL.puts_header "AAAAAAAAAAAAAAAAAAAAAAAAA early exit for testing"
# exit
