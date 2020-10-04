source_paths.unshift(File.dirname(__FILE__))

directory "spec/performance"
copy_file "spec/performance/home_page_spec.rb"
copy_file "spec/support/shared_examples/a_performant_page.rb"
copy_file "spec/performance_helper.rb"
