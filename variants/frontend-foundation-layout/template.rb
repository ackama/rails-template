source_paths.unshift(File.dirname(__FILE__))

apply "app/frontend/foundation/template.rb"
directory "app/views/application"
directory "app/frontend/images"
directory "app/views/home"

gsub_file "app/views/layouts/application.html.erb", "<body>", "<body class=\"no-js\">"
gsub_file "app/views/layouts/application.html.erb", 
          "render(\"application/flash\")", 
          "render(\"application/header/header\")"

insert_into_file "app/views/layouts/application.html.erb", "    <%= render(\"application/footer\") %>", after: "<%= yield %>"