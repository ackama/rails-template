require "json"

source_paths.unshift(File.dirname(__FILE__))

# Configure app/assets

remove_file "app/assets/config/manifest.js"
create_file "app/assets/config/manifest.js" do
  <<~EO_CONTENT
  // This file must exist for assets pipeline compatibility.
  EO_CONTENT
end
remove_dir "app/assets/stylesheets"
remove_dir "app/assets/images"

# Configure app/frontend

run "mv app/javascript app/frontend"

gsub_file "config/webpacker.yml", "source_path: app/javascript", "source_path: app/frontend", force: true

# Yarn's integrity check command is quite buggy, to the point that yarn v2 removed it
#
# The integrity check option itself has been removed in webpacker v5.1 but we
# currently pull in v4, so we just set it to false to be safe
#
gsub_file "config/webpacker.yml", "check_yarn_integrity: true", "check_yarn_integrity: false", force: true

# We want webpacker to generate a separate CSS file in all environments because
#
# 1. It makes things look more "normal" in browser dev tools
# 2. We don't have to add 'unsafe-inline' to the CSP header to allow Webpack to
#    create inline stylesheets
#
gsub_file "config/webpacker.yml", "  extract_css: false", "  extract_css: true", force: true

empty_directory_with_keep_file "app/frontend/images"
copy_file "app/frontend/stylesheets/application.scss"
copy_file "app/frontend/stylesheets/_elements.scss"
prepend_to_file "app/frontend/packs/application.js" do
  <<~EO_CONTENT

  import '../stylesheets/application.scss';
  EO_CONTENT
end

# Configure app/views
gsub_file "app/views/layouts/application.html.erb",
          "<%= stylesheet_link_tag(",
          "<%= stylesheet_pack_tag(",
          force: true

body_open_tag_with_img_example = <<~EO_IMG_EXAMPLE
  <body>
      <%
        # An example of how to load an image via Webpacker. This image is in
        # app/frontend/images/example.png
      %>
      <%# image_pack_tag "example.png", alt: "Example Image" %>
EO_IMG_EXAMPLE
gsub_file "app/views/layouts/application.html.erb", "<body>", body_open_tag_with_img_example, force: true
