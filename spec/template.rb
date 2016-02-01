copy_file "spec/rails_helper.rb", :force => true
copy_file "spec/spec_helper.rb", :force => true
copy_file "spec/support/capybara.rb"
copy_file "spec/support/database_cleaner.rb"
copy_file ".rspec"
empty_directory_with_keep_file "spec/models"
empty_directory_with_keep_file "spec/controllers"
empty_directory_with_keep_file "spec/features"
empty_directory_with_keep_file "spec/factories"
copy_file "spec/features/home_feature_spec.rb"
