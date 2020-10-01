source_paths.unshift(File.dirname(__FILE__))

puts "Adding react-rails to Gemfile"

gem "react-rails"
run "bundle install"

run "rails webpacker:install:react"
run "rails generate react:install"
run "rails g react:component HelloWorld greeting:string"


insert_into_file "app/views/layouts/application.html.erb",
          after: /<%= javascript_pack_tag \"application\", \"data-turbolinks-track\": \"reload\", defer: true %>\n/ do
  <<-ERB
    <%= javascript_pack_tag "application" %>
  ERB
end

append_to_file "app/views/home/index.html.erb" do
  <<~ERB
    <%= react_component("HelloWorld", { greeting: "Hello from react-rails." }) %>
  ERB
end