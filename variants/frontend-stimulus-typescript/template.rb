source_paths.unshift(File.dirname(__FILE__))

remove_file "app/frontend/stimulus/controllers/hello_controller.js", force: true
copy_file "app/frontend/stimulus/controllers/hello_controller.ts"
