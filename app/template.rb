copy_file "app/assets/stylesheets/application.scss"
remove_file "app/assets/stylesheets/application.css"

copy_file "app/controllers/home_controller.rb"
template "app/views/layouts/application.html.erb", :force => true
copy_file "app/views/shared/_flash.html.erb"
copy_file "app/views/home/index.html.erb"

remove_dir "app/jobs"
empty_directory_with_keep_file "app/workers"
