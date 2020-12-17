# Javascript code linting and formatting
# ######################################

run "rm .browserslistrc"
run "yarn add --dev eslint eslint-config-ackama eslint-plugin-node eslint-plugin-import eslint-plugin-prettier prettier prettier-config-ackama eslint-plugin-eslint-comments eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y"
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

append_to_file "bin/ci-run" do
  <<~AUDIT
  echo "* ******************************************************"
  echo "* Running JS package audit"
  echo "* ******************************************************"
  yarn audit
  AUDIT
end
