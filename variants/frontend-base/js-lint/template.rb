# Javascript code linting and formatting
# ######################################

run "rm .browserslistrc"
yarn_add_dev_dependencies %w[
  eslint
  eslint-config-ackama
  eslint-plugin-node
  eslint-plugin-import
  eslint-plugin-prettier
  eslint-plugin-eslint-comments
  prettier
  prettier-config-ackama
  prettier-plugin-packagejson
]
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

gsub_file "app/frontend/channels/index.js",
          "/_channel\\.js$/",
          "/_channel\\.js$/u"

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
yarn_add_dev_dependencies %w[
  stylelint
  stylelint-scss
  stylelint-config-recommended-scss
]
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
