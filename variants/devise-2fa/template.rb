# Allow us to copy file with root at the directory this file is in
source_paths.unshift(File.dirname(__FILE__))

def print_header(msg)
  puts "=" * 80
  puts msg
  puts "=" * 80
end

print_header "Adding devise-two-factor, rqrcode-rails3 to Gemfile"
run "bundle add devise-two-factor"
run "bundle add rqrcode-rails3"

print_header "Adding OTP info to user model"
run "bundle exec rails generate devise_two_factor User DEVISE_TWO_FACTOR_SECRET_ENCRYPTION_KEY"

gsub_file("app/models/user.rb", "ENV['DEVISE_TWO_FACTOR_SECRET_ENCRYPTION_KEY']", "Rails.application.secrets.devise_two_factor_secret_encryption_key")

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

insert_into_file("app/views/users/sessions/new.html.erb", before: /^.*<div class="actions">/) do
  <<~EO_FIELD
    <div class="form__field">
      <%= f.label :otp_attempt, "2FA (Two Factor Auth) code", class: "form__label" %><br />
      <%= f.text_field :otp_attempt, class: "form__input" %>
    </div>
  EO_FIELD
end

append_to_file("config/initializers/filter_parameter_logging.rb") do
  <<~EO_CONTENT
    Rails.application.config.filter_parameters += %i[otp_attempt]
  EO_CONTENT
end

# TODO: got to clean up stuff to keep rubocop happy
print_header "Running rubocop to clean up generated files"
run "bundle exec rubocop -A"
