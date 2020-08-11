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
append_to_file "app/frontend/packs/application.js" do
  <<~EO_CONTENT

  import '../stylesheets/application.scss';
  EO_CONTENT
end

enable_imgs_src = <<~EO_SRC
  //
  // const images = require.context('../images', true)
  // const imagePath = (name) => images(name, true)
EO_SRC
enable_imgs_replacement = <<~EO_REPLACEMENT

  const images = require.context('../images', true);
  // eslint-disable-next-line no-unused-vars
  const imagePath = name => images(name, true);
EO_REPLACEMENT
gsub_file "app/frontend/packs/application.js", enable_imgs_src, enable_imgs_replacement

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

# Setup Sentry
# ############

run "yarn add @sentry/browser"
run "yarn add dotenv-webpack -D"

gsub_file "config/webpack/environment.js",
  "module.exports = environment",
  <<~'EO_JS'
    const Dotenv = require('dotenv-webpack');

    environment.plugins.prepend('Dotenv', new Dotenv());

    module.exports = environment;
  EO_JS

append_to_file "app/frontend/packs/application.js" do
  <<~'EO_JS'

    // Initialize Sentry Error Reporting
    //
    // Import all your application's JS after this section because we need Sentry
    // to be initialized **before** we import any of our actual JS so that Sentry
    // can report errors from it.
    //
    import * as Sentry from '@sentry/browser';
    Sentry.init({
      dsn: process.env.SENTRY_DSN,
      environment: process.env.SENTRY_ENV || process.env.RAILS_ENV
    });

    // Uncomment this Sentry by sending an exception every time the page loads.
    // Obviously this is a very noisy activity and we do have limits on Sentry so
    // you should never do this on a deployed environment.
    //
    // Sentry.captureException(new Error('Away-team to Enterprise, two to beam directly to sick bay...'));

    // Import all your application's JS here
    //
    // import '../javascript/example-1.js';
    // import { someFunc } from '../javascript/funcs.js';
  EO_JS
end

prepend_to_file "app/frontend/packs/application.js" do
  <<~'EO_JS'
    // The application.js pack is defered by default which means that nothing imported 
    // in this file will begin executing until after the page has loaded. This helps to 
    // speed up page loading times, especially in apps that have large amounts of js.
    //  
    // If you have javascript that *must* execute before the page has finished loading, 
    // create a separate 'boot.js' pack in the frontend/packs directory and import any 
    // required files in that. Also remember to add a separate pack_tag entry with:
    // <%= javascript_pack_tag "boot", "data-turbolinks-track": "reload" %> 
    // to the views/layouts/application.html.erb file above the existing application pack tag.
    // 
  EO_JS
end

gsub_file "config/initializers/content_security_policy.rb",
  /# policy.report_uri ".+"/,
  'policy.report_uri ENV.fetch("SENTRY_CSP_HEADER_REPORT_ENDPOINT")'

# Javascript code linting and formatting
# ######################################

run "rm .browserslistrc"
run "yarn add --dev eslint eslint-config-ackama eslint-plugin-import eslint-plugin-prettier prettier prettier-config-ackama eslint-plugin-eslint-comments eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y"
copy_file ".eslintrc.js"
template ".prettierignore.tt"

package_json = JSON.parse(File.read("./package.json"))
package_json["prettier"] = "prettier-config-ackama"
package_json["browserslist"] = [
  "defaults",
  "not IE 11",
  "not IE_Mob 11"
]
package_json["scripts"] = {
  "js-lint" => "eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx",
  "js-lint-fix" => "eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx --fix",
  "format-check" => "prettier --check './**/*.{css,scss,json,md,js,ts,tsx,jsx}'",
  "format-fix" => "prettier --write './**/*.{css,scss,json,md,js,ts,tsx,jsx}'",
  "scss-lint" => "stylelint '**/*.{css,scss}'",
  "scss-lint-fix" => "stylelint '**/*.{css,scss}' --fix"
}

File.write("./package.json", JSON.generate(package_json))

# fix js lint issues with generated defaults before linting runs
gsub_file "babel.config.js",
          "module.exports = function(api) {",
          "module.exports = api => {"

gsub_file "app/frontend/channels/index.js",
          "/_channel\\.js$/",
          "/_channel\\.js$/u"

prepend_to_file "postcss.config.js" do
  <<~ESLINTFIX
  /* eslint-disable global-require */ 
  'use strict'; \n
  ESLINTFIX
end

prepend_to_file "babel.config.js", "'use strict';"
prepend_to_file "config/webpack/development.js", "'use strict';"
prepend_to_file "config/webpack/environment.js", "'use strict';"
prepend_to_file "config/webpack/production.js", "'use strict';"
prepend_to_file "config/webpack/test.js", "'use strict';"

# must be run after prettier is installed and has been configured by setting
# the 'prettier' key in package.json
run "yarn run js-lint-fix"
run "yarn run format-fix"

append_to_file "bin/ci-run" do
  <<~ESLINT

  echo "* ******************************************************"
  echo "* Running JS linting"
  echo "* ******************************************************"
  yarn run js-lint
  ESLINT
end

append_to_file "bin/ci-run" do
  <<~PRETTIER

  echo "* ******************************************************"
  echo "* Running JS linting"
  echo "* ******************************************************"
  yarn run format-check
  PRETTIER
end

# SCSS Linting
run "yarn add --dev stylelint stylelint-scss stylelint-config-recommended-scss"
copy_file ".stylelintrc.js"
template ".stylelintignore.tt"

append_to_file "bin/ci-run" do
  <<~SASSLINT

  echo "* ******************************************************"
  echo "* Running SCSS linting"
  echo "* ******************************************************"
  yarn run scss-lint
  SASSLINT
end
