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

# this will create a package.json for us
run "rails webpacker:install"

# Configure app/frontend

run "mv app/javascript app/frontend"
run "mkdir app/frontend/packs"
run "mv app/frontend/application.js app/frontend/packs/application.js"

copy_file "config/webpack/webpack.config.js", force: true

gsub_file "config/webpacker.yml", "source_entry_path: /", "source_entry_path: packs", force: true
gsub_file "config/webpacker.yml", "cache_path: tmp/webpacker", "cache_path: tmp/cache/webpacker", force: true
gsub_file "config/webpacker.yml", "source_path: app/javascript", "source_path: app/frontend", force: true

# Yarn's integrity check command is quite buggy, to the point that yarn v2 removed it
#
# The integrity check option itself has been removed in webpacker v5.1 but we
# currently pull in v4, so we just set it to false to be safe
#
gsub_file "config/webpacker.yml", "check_yarn_integrity: true", "check_yarn_integrity: false", force: true

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

# shakapacker will automatically configure webpack to use these so long as the dependencies are present
yarn_add_dependencies %w[
  css-loader
  css-minimizer-webpack-plugin
  mini-css-extract-plugin
  sass
  sass-loader
]
