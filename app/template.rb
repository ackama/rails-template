copy_file "app/assets/stylesheets/application.scss"
remove_file "app/assets/stylesheets/application.css"

template "app/controllers/application_controller.rb", force: true
copy_file "app/controllers/home_controller.rb"
template "app/views/layouts/application.html.erb", force: true
copy_file "app/views/application/_flash.html.erb"
copy_file "app/views/home/index.html.erb"

copy_file "app/helpers/retina_image_helper.rb"

remove_dir "app/jobs"
empty_directory_with_keep_file "app/workers"
