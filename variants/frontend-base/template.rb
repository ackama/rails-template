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

# ensure our preferred js package manager is specified before running external tooling
package_json.record_package_manager!

run "rails shakapacker:install"

# ensure the latest major versions of Shakapacker's peer dependencies are installed
#
# TODO: remove this once https://github.com/shakacode/shakapacker/pull/576 is landed
add_js_dependencies [
  "babel-loader@10",
  "compression-webpack-plugin@11",
  "webpack-assets-manifest@6",
  "webpack-cli@6",
  "webpack-merge@6"
]
add_js_dependencies ["webpack-dev-server@5"], type: :dev

# this is added by shakapacker:install, but we've already got one (with some extra tags)
# in our template, so remove theirs otherwise the app will error when rendering this
gsub_file! "app/views/layouts/application.html.erb",
           "    <%= javascript_pack_tag \"application\" %>\n",
           ""

# Configure app/frontend

run "mv app/javascript app/frontend"

copy_file "babel.config.js", force: true

# we've replaced this with a babel.config.js
package_json.delete!("babel")

copy_file "config/webpack/webpack.config.js", force: true

gsub_file! "config/shakapacker.yml", "cache_path: tmp/shakapacker", "cache_path: tmp/cache/shakapacker"
gsub_file! "config/shakapacker.yml", "source_path: app/javascript", "source_path: app/frontend"

old_shakapacker_test_compile_snippet = <<~EO_OLD
  test:
    <<: *default
    compile: true
EO_OLD
new_shakapacker_test_compile_snippet = <<~EO_NEW
  test:
    <<: *default

    # We pre-compile assets before running system tests so we do not want
    # Shakapacker to automatically compile in the test env
    compile: false
EO_NEW
gsub_file!("config/shakapacker.yml", old_shakapacker_test_compile_snippet, new_shakapacker_test_compile_snippet, force: true)

empty_directory_with_keep_file "app/frontend/images"
copy_file "app/frontend/stylesheets/_elements.scss"
copy_file "app/frontend/stylesheets/_reset.scss"
copy_file "app/frontend/stylesheets/application.scss"
prepend_to_file! "app/frontend/packs/application.js" do
  <<~EO_CONTENT

    import "../stylesheets/application.scss";
  EO_CONTENT
end

images_disabled_chunk = <<~EO_IMAGES_DISABLED
  // const images = require.context('./images', true)
  // const imagePath = (name) => images(name, true)
EO_IMAGES_DISABLED

images_enabled_chunk = <<~EO_ENABLE_IMAGES
  const images = require.context('../images', true);
  // eslint-disable-next-line no-unused-vars
  const imagePath = name => images(name, true);
EO_ENABLE_IMAGES

gsub_file! "app/frontend/packs/application.js", images_disabled_chunk, images_enabled_chunk, force: true

# Configure app/views
gsub_file! "app/views/layouts/application.html.erb",
           "<%= stylesheet_link_tag(",
           "<%= stylesheet_pack_tag(",
           force: true

copy_file "app/frontend/images/example.png"
body_open_tag_with_img_example = <<~EO_IMG_EXAMPLE
  <body>
      <%
        # An example of how to load an image via shakapacker. This image is in
        # app/frontend/images/example.png
      %>
      <%= image_pack_tag "images/example.png", alt: "Example Image" %>
EO_IMG_EXAMPLE
gsub_file! "app/views/layouts/application.html.erb", "<body>", body_open_tag_with_img_example, force: true

# shakapacker will automatically configure webpack to use these so long as the dependencies are present
add_js_dependencies %w[
  css-loader
  css-minimizer-webpack-plugin
  mini-css-extract-plugin
  sass
  sass-loader
]

# Setup Turbo
add_js_dependencies %w[
  @hotwired/turbo-rails
]
prepend_to_file! "app/frontend/packs/application.js" do
  <<~EO_CONTENT

    import "@hotwired/turbo-rails"
  EO_CONTENT
end
