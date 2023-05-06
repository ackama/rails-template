# Configure app/controllers
copy_file "variants/backend-base/app/controllers/home_controller.rb", "app/controllers/home_controller.rb"
copy_file "variants/backend-base/app/controllers/active_storage/base_controller.rb", "app/controllers/active_storage/base_controller.rb"

# Configure app/views
template "variants/backend-base/app/views/layouts/application.html.erb", "app/views/layouts/application.html.erb", force: true
copy_file "variants/backend-base/app/views/application/_flash.html.erb", "app/views/application/_flash.html.erb"
copy_file "variants/backend-base/app/views/application/_header.html.erb", "app/views/application/_header.html.erb"
copy_file "variants/backend-base/app/views/home/index.html.erb", "app/views/home/index.html.erb"

# Configure app/helpers
directory "variants/backend-base/app/middleware", "app/middleware"

# Configure empty dirs under app/
remove_dir "app/jobs"
empty_directory_with_keep_file "app/workers"
empty_directory_with_keep_file "app/services"

# Configure the default mailer to use the our default from address
gsub_file "app/mailers/application_mailer.rb",
          "default from: 'from@example.com'",
          "default from: Rails.application.secrets.mail_from"
