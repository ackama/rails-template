copy_file "variants/backend-base/spec/rails_helper.rb", "spec/rails_helper.rb", force: true
copy_file "variants/backend-base/spec/spec_helper.rb", "spec/spec_helper.rb", force: true
copy_file "variants/backend-base/.rspec", ".rspec"
directory "variants/backend-base/spec/system", "spec/system"
directory "variants/backend-base/spec/requests", "spec/requests"
empty_directory_with_keep_file "spec/helpers"
empty_directory_with_keep_file "spec/models"
empty_directory_with_keep_file "spec/factories"
empty_directory_with_keep_file "spec/support"
