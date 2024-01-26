# Javascript code linting and formatting
# ######################################

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
copy_file "variants/frontend-base/.eslintrc.js", ".eslintrc.js"
template "variants/frontend-base/.prettierignore.tt", ".prettierignore"

update_package_json do |package_json|
  package_json["prettier"] = "prettier-config-ackama"
  package_json["browserslist"] = ["defaults"]
  package_json["scripts"] = {
    "js-lint" => "eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx",
    "js-lint-fix" => "eslint . --ignore-pattern '!.eslintrc.js' --ext js,ts,tsx,jsx --fix",
    "format-check" => "prettier --check .",
    "format-fix" => "prettier --write .",
    "scss-lint" => "stylelint '**/*.{css,scss}'",
    "scss-lint-fix" => "stylelint '**/*.{css,scss}' --fix"
  }
end

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
  postcss
  stylelint
  stylelint-scss
  stylelint-config-recommended-scss
]
copy_file "variants/frontend-base/.stylelintrc.js", ".stylelintrc.js"
template "variants/frontend-base/.stylelintignore.tt", ".stylelintignore"

append_to_file "bin/ci-run" do
  <<~SASSLINT

    echo "* ******************************************************"
    echo "* Running SCSS linting"
    echo "* ******************************************************"
    yarn run scss-lint
  SASSLINT
end
