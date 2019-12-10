require "json"

source_paths.unshift(File.dirname(__FILE__))

run "mv app/assets app/frontend"
run "mkdir app/assets"
run "mv app/frontend/config app/assets/config"

run "mv app/javascript/* app/frontend"
run "rm -rf app/javascript"
apply "config/template.rb"
apply "app/template.rb"

# Javascript code linting and formatting
run "yarn add --dev eslint eslint-plugin-prettier eslint-config-prettier eslint-plugin-eslint-comments eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y prettier prettier-config-ackama"
copy_file ".eslintrc.js"
template ".eslintignore.tt"
template ".prettierignore.tt"

package_json = JSON.parse(File.read("./package.json"))
package_json["prettier"] = "prettier-config-ackama"
package_json["scripts"] = {
  "js-lint" => "eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx",
  "js-lint-fix" => "eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx --fix",
  "format-check" => "prettier --check './**/*.{css,scss,json,md,js,ts,tsx,jsx}'",
  "format-fix" => "prettier --write './**/*.{css,scss,json,md,js,ts,tsx,jsx}'",
  "scss-lint" => "stylelint '**/*.{css,scss}'",
  "scss-lint-fix" => "stylelint '**/*.{css,scss}' --fix"
}
File.write("./package.json", JSON.generate(package_json))

# must be run after prettier is installed and has been configured by setting
# the 'prettier' key in package.json
run "yarn run js-lint-fix"
run "yarn run format-fix"

append_to_file "bin/ci-test-pipeline-1" do
  <<~ESLINT

  echo "* ******************************************************"
  echo "* Running JS linting"
  echo "* ******************************************************"
  yarn run js-lint
  ESLINT
end

append_to_file "bin/ci-test-pipeline-1" do
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

append_to_file "bin/ci-test-pipeline-1" do
  <<~SASSLINT

  echo "* ******************************************************"
  echo "* Running SCSS linting"
  echo "* ******************************************************"
  yarn run scss-lint
  SASSLINT
end
