# this applies the js-linting tools to the app, and so should be run after *all*
# frontend variants have finished running to ensure that we don't cause any
# overrides or miss files

# we need to do this *after* other variants, as @rails/webpacker will block
# if it needs to modify <code>babel.config.js</code> and we've already modified
prepend_to_file "babel.config.js", "'use strict';"
gsub_file "babel.config.js",
          " = function (api) {",
          " = api => {"

prepend_to_file "postcss.config.js" do
  <<~ESLINTFIX
    /* eslint-disable node/global-require */
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
