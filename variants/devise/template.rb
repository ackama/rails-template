# Allow us to copy file with root at the directory this file is in
source_paths.unshift(File.dirname(__FILE__))

TERMINAL.puts_header "Adding devise to Gemfile"
run "bundle add devise -v '~> 5.0'"

TERMINAL.puts_header "Running devise generator"
run "bundle exec rails generate devise:install"

TERMINAL.puts_header "Generating User model with devise"
run "bundle exec rails generate devise User"

gsub_file! "app/models/user.rb",
           ":validatable",
           ":validatable, :lockable"

devise_migration_filename = Dir.children("db/migrate").find { |filename| filename.end_with?("_devise_create_users.rb") }
devise_migration_path = "db/migrate/#{devise_migration_filename}"

TERMINAL.puts_header "Tweaking auto-generated devise migration '#{devise_migration_path}'"
gsub_file! devise_migration_path,
           "      # t.integer  :failed_attempts",
           "      t.integer  :failed_attempts"
gsub_file! devise_migration_path,
           "      # t.string   :unlock_token",
           "      t.string   :unlock_token"
gsub_file! devise_migration_path,
           "      # t.datetime :locked_at",
           "      t.datetime :locked_at"
gsub_file! devise_migration_path,
           "    # add_index :users, :unlock_token",
           "    add_index :users, :unlock_token"

TERMINAL.puts_header "Running db migration"
run "bundle exec rails db:migrate"

TERMINAL.puts_header "Copying devise views into the application"
run "bundle exec rails generate devise:views users"

##
# Tweak the generated devise config file
#
TERMINAL.puts_header "Tweaking config/initializers/devise.rb"

gsub_file! "config/initializers/devise.rb",
           "  config.mailer_sender = 'please-change-me-at-config-initializers-devise@example.com'",
           "  config.mailer_sender = Rails.application.config.app.mail_from"

gsub_file! "config/initializers/devise.rb",
           "  # config.scoped_views = false",
           "  config.scoped_views = true"

gsub_file! "config/initializers/devise.rb",
           "  config.password_length = 6..128",
           "  config.password_length = 16..128"

gsub_file! "config/initializers/devise.rb",
           "  # config.paranoid = true",
           "  config.paranoid = true"

gsub_file! "config/initializers/devise.rb",
           /  # config.secret_key = '.+'/,
           "  # config.secret_key = 'do_not_put_secrets_in_source_control_please'"

gsub_file! "config/initializers/devise.rb",
           /  # config.lock_strategy = .+/,
           "  config.lock_strategy = :failed_attempts"

gsub_file! "config/initializers/devise.rb",
           /  # config.unlock_strategy = .+/,
           "  config.unlock_strategy = :email"

gsub_file! "config/initializers/devise.rb",
           "  # config.parent_mailer = 'ActionMailer::Base'",
           "  config.parent_mailer = 'ApplicationMailer'"

gsub_file! "config/initializers/devise.rb",
           /  # config.maximum_attempts = .+/,
           <<-EO_CHUNK
  #
  # https://www.nzism.gcsb.govt.nz/ism-document/#1887 recommends 3 as a default. FYI to
  # be fully compliant with https://www.nzism.gcsb.govt.nz/ism-document/#1887 then only
  # Administrators should be able to unlock.
  config.maximum_attempts = 3
           EO_CHUNK

gsub_file! "config/initializers/devise.rb",
           /  # config.last_attempt_warning = .+/,
           "  config.last_attempt_warning = true"

##
# Add a block to config/routes.rb demonstrating how to create authenticated
# routes
#
TERMINAL.puts_header "Adding exemplar authenticated routes"
route <<-EO_ROUTES

  authenticate :user do
    # routes created within this block can only be accessed by a user who has
    # logged in. For example:
    # resources :things
  end

EO_ROUTES

##
# Add links to user sign-in and sign-up to the homepage to help ensure that
# devs know they have both things enabled in the application now.
#
TERMINAL.puts_header "Adding example devise links to the homepage"

append_to_file! "app/views/application/_header.html.erb" do
  <<~ERB
    <%=
      content_tag(:style, nonce: content_security_policy_nonce) do
        <<~STYLE
          /* Temp style to pass Lighthouse audit */
          a { display: block; padding: 0.5rem; }
          input { padding: 0.5rem; margin: 0.5rem; }
        STYLE
      end
    %>
    <nav class="navbar navbar-expand-sm navbar-light bg-light">
      <div class="container-fluid">
        <h1>Example devise nav</h1>
        <ul class="navbar-nav">
          <li class="nav-item"><%= link_to "Home", root_path, class: "nav-link" %></li>
          <% if current_user %>
            <li class="navbar-text">You are <strong>Signed in</strong></li>
            <li class="nav-item"><%= button_to "Sign out", destroy_user_session_path, method: :delete, class: "nav-link" %></li>
          <% else %>
            <li class="navbar-text">You are <strong>Not signed in</strong></li>
            <li class="nav-item"><%= link_to "Sign in", new_user_session_path, class: "nav-link" %></li>
            <li class="nav-item"><%= link_to "Sign up", new_user_registration_path, class: "nav-link" %></li>
          <% end %>
        </ul>
      </div>
    </nav>
  ERB
end

TERMINAL.puts_header "Fixing session cookie expiry"

run "bundle exec rails g migration AddSessionTokenToUser session_token:string"
run "bundle exec rails db:migrate"

copy_file "app/controllers/users/sessions_controller.rb"

gsub_file! "config/routes.rb",
           "devise_for :users",
           <<~EO_DEVISE
             devise_for :users, controllers: {
               sessions: "users/sessions"
             }
           EO_DEVISE

insert_into_file! "app/models/user.rb", before: /^end/ do
  <<~'RUBY'

    ##
    # The `session_token` attribute is used to build the Devise
    # `authenticatable_salt` so changing the `session_token` has the effect of
    # invalidating any existing sessions for the current user.
    #
    # This method is called by Users::SessionsController#destroy to make sure
    # that when a user logs out (i.e. destroys their session) then the session
    # cookie they had cannot be used again. This closes a security issue with
    # cookie based sessions.
    #
    # References
    #   * https://github.com/plataformatec/devise/issues/3031
    #   * http://maverickblogging.com/logout-is-broken-by-default-ruby-on-rails-web-applications/
    #   * https://makandracards.com/makandra/53562-devise-invalidating-all-sessions-for-a-user
    #
    def invalidate_all_sessions!
      update!(session_token: SecureRandom.hex(16))
    end

    ##
    # devise calls this method to generate a salt for creating the session
    # cookie. We override the built-in devise implementation (which comes from
    # the devise `authenticable` module - see link below) to also include our
    # `session_token` attribute. This means that whenever the session_token
    # changes, the user's session cookie will be invalidated.
    #
    # `session_token` is `nil` until the user has signed out once. That is fine
    # because we only care about making the `session_token` **different** after
    # they logout so that the cookie is invalidated.
    #
    # References
    #  * https://github.com/heartcombo/devise/blob/master/lib/devise/models/authenticatable.rb#L97-L98
    #
    def authenticatable_salt
      "#{super}#{session_token}"
    end
  RUBY
end

TERMINAL.puts_header "Writing tests for you - you're welcome!"

copy_file "spec/models/user_spec.rb", force: true

copy_file "spec/factories/users.rb", force: true

copy_file "spec/system/user_sign_in_feature_spec.rb"
copy_file "spec/system/user_sign_up_feature_spec.rb"
copy_file "spec/system/user_reset_password_feature_spec.rb"
copy_file "spec/requests/session_cookie_expiry_spec.rb"

# tell pundit not to check that authorization was called on devise controllers
gsub_file!("app/controllers/application_controller.rb",
           "after_action :verify_authorized, except: :index",
           "after_action :verify_authorized, except: :index, unless: :devise_controller?"
          )
gsub_file!("app/controllers/application_controller.rb",
           "after_action :verify_policy_scoped, only: :index",
           "after_action :verify_policy_scoped, only: :index, unless: :devise_controller?"
          )

TERMINAL.puts_header "Running rubocop -A to fix formatting in files generated by devise"
run "bundle exec rubocop -A -c ./.rubocop.yml"

git add: "-A ."
git commit: "-n -m 'Install and configure devise with default Ackama settings'"

prepend_to_file! "app/views/users/shared/_error_messages.html.erb", "<%# locals: (resource:) %>\n\n"
prepend_to_file! "app/views/users/shared/_links.html.erb", "<%# locals: () %>\n\n"
