# Configure app/controllers
copy_file "app/controllers/home_controller.rb"

# Configure app/views
template "app/views/layouts/application.html.erb", force: true
copy_file "app/views/application/_flash.html.erb"
copy_file "app/views/home/index.html.erb"

# Configure app/helpers
copy_file "app/helpers/retina_image_helper.rb"
directory "app/middleware"

# Configure empty dirs under app/
remove_dir "app/jobs"
empty_directory_with_keep_file "app/workers"
empty_directory_with_keep_file "app/services"
