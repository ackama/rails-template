gsub_file "app/views/layouts/application.html.erb",
          "<%= stylesheet_link_tag ",
          "<%= stylesheet_pack_tag ",
          force: true