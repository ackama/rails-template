copy_file "spec/rails_helper.rb", :force => true
copy_file "spec/spec_helper.rb", :force => true
copy_file ".rspec"
directory "spec/system"
directory "spec/requests"
directory "spec/helpers"
empty_directory_with_keep_file "spec/models"
empty_directory_with_keep_file "spec/factories"
empty_directory_with_keep_file "spec/support"
copy_file "spec/support/helpers/download_helper.rb", force: true
copy_file "spec/features/download/download_spec.rb", force: true
