# Allow us to copy file with root at the directory this file is in
source_paths.unshift(File.dirname(__FILE__))

def print_header(msg)
  puts "=" * 80
  puts msg
  puts "=" * 80
end

######################################
# Gemfile
######################################

print_header "Adding devise-two-factor, rqrcode-rails3 to Gemfile"
run "bundle add devise-two-factor"
run "bundle add rqrcode-rails3"

######################################
# User model
######################################

print_header "Adding OTP info to user model"
run "bundle exec rails generate devise_two_factor User DEVISE_TWO_FACTOR_SECRET_ENCRYPTION_KEY"

gsub_file("app/models/user.rb", "ENV['DEVISE_TWO_FACTOR_SECRET_ENCRYPTION_KEY']", "Rails.application.secrets.devise_two_factor_secret_encryption_key")

######################################
# Controllers
######################################

######################################
# Secrets
######################################

insert_into_file("config/secrets.yml", after: /\A.+secret_key_base.+\z/) do
  <<-EO_LINE
    devise_two_factor_secret_encryption_key: "<%= ENV['DEVISE_TWO_FACTOR_SECRET_ENCRYPTION_KEY'] %>"
  EO_LINE
end

append_to_file ".env" do
  <<~EO_LINE

    # Use 'bundle exec rails secret' to generate a real value here
    DEVISE_TWO_FACTOR_SECRET_ENCRYPTION_KEY=fortheloveofallyouholddeardonotusethissecretinproduction
  EO_LINE
end

######################################
# Views
######################################

insert_into_file("app/views/users/sessions/new.html.erb", before: /^.*<div class="actions">/) do
  <<~EO_FIELD
    <div class="form__field">
      <%= f.label :otp_attempt, "2FA (Two Factor Auth) code", class: "form__label" %><br />
      <%= f.text_field :otp_attempt, class: "form__input" %>
    </div>
  EO_FIELD
end

######################################
# Config
######################################

append_to_file("config/initializers/filter_parameter_logging.rb") do
  <<~EO_CONTENT
    Rails.application.config.filter_parameters += %i[otp_attempt]
  EO_CONTENT
end

# TODO: devise initializer
#  # This must be set to false when using devise-two-factor - see
#   # https://github.com/tinfoil/devise-two-factor#disabling-automatic-login-after-password-resets
#   config.sign_in_after_reset_password = false
# # ==> Controller configuration
# # Configure the parent class to the devise controllers.
# config.parent_controller = "Users::DeviseController"
# TODO:
# this is a fix for https://github.com/heartcombo/devise/issues/5439 but I'm not sure it is the best fix
# config.navigational_formats = ["*/*", :html, :turbo_stream]

# TODO: migrations

######################################
# Documentation
######################################

# TODO: documentation

######################################
# Clean up
######################################

print_header "Running rubocop to clean up generated files"
run "bundle exec rubocop -A"
