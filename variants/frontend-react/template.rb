source_paths.unshift(File.dirname(__FILE__))

puts "Adding react-rails to Gemfile"

gem "react-rails"
run "bundle install"

run "rails webpacker:install:react"
run "rails generate react:install"
run "rails g react:component HelloWorld greeting:string"
