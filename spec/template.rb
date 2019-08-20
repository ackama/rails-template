copy_file "spec/rails_helper.rb", :force => true
copy_file "spec/spec_helper.rb", :force => true
copy_file ".rspec"
empty_directory_with_keep_file "spec/models"
empty_directory_with_keep_file "spec/controllers"
empty_directory_with_keep_file "spec/helpers"
empty_directory_with_keep_file "spec/system"
empty_directory_with_keep_file "spec/factories"
empty_directory_with_keep_file "spec/support"
copy_file "spec/system/home_feature_spec.rb"
copy_file "spec/helpers/retina_image_helper_spec.rb"
