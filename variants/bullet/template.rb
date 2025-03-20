insert_into_file! "Gemfile", after: /^group :development, :test do\n/ do
  <<~GEMS
    gem "bullet", ">= 8.0" # Rails 8+ requires Bullet 8+
  GEMS
end

run "bundle install"

insert_into_file! "config/environments/development.rb", before: /^end/ do
  <<-RUBY

  # Bullet makes inline javascript, so there is warning in console in browse until content security policy change
  config.after_initialize do
    Bullet.enable        = true
    Bullet.raise         = true # raise an error if n+1 query occurs
    Bullet.bullet_logger = true
    Bullet.rails_logger  = true

    # Because it is against our default policy in content_security_policy.rb,
    # these do not execute until policy change,
    # Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
    # policy.script_src  :self, :unsafe_inline
    # policy.style_src   :self, :unsafe_inline

    # Bullet.alert         = true
    # Bullet.console       = true
    # Bullet.add_footer    = true
  end
  RUBY
end

insert_into_file! "config/environments/test.rb", before: /^end/ do
  <<-RUBY

  config.after_initialize do
    Bullet.enable        = true
    Bullet.bullet_logger = true
    Bullet.raise         = true # raise an error if n+1 query occurs
  end
  RUBY
end
