copy_file "app/assets/stylesheets/application.scss"
remove_file "app/assets/stylesheets/application.css"

copy_file "app/controllers/home_controller.rb"
template "app/views/layouts/application.html.erb", force: true
copy_file "app/views/application/_flash.html.erb"
copy_file "app/views/home/index.html.erb"

copy_file "app/helpers/retina_image_helper.rb"
directory "app/middleware"

remove_dir "app/jobs"
empty_directory_with_keep_file "app/workers"
empty_directory_with_keep_file "app/services"
