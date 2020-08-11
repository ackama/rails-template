source_paths.unshift(File.dirname(__FILE__))

apply "Gemfile.rb"
apply "spec/system/home_feature_spec.rb"
copy_file "spec/support/shared_examples/an_accessible_page.rb"