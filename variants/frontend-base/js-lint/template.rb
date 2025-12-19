# Javascript code linting and formatting
# ######################################

add_js_dependencies %w[
  @eslint-community/eslint-plugin-eslint-comments
  @stylistic/eslint-plugin-js@3
  @eslint/js
  eslint
  eslint-config-ackama
  eslint-plugin-n
  eslint-plugin-import
  eslint-plugin-prettier
  globals
  prettier
  prettier-config-ackama
], type: :dev

copy_file "variants/frontend-base/eslint.config.js", "eslint.config.js"
template "variants/frontend-base/.prettierignore.tt", ".prettierignore"

package_json.merge! do |pj|
  {
    "prettier" => "prettier-config-ackama",
    "browserslist" => ["defaults"],
    "scripts" => pj.fetch("scripts", {}).merge({
      "js-lint" => "eslint",
      "js-lint-fix" => "eslint --fix",
      "format-check" => "prettier --check .",
      "format-fix" => "prettier --write .",
      "scss-lint" => "stylelint '**/*.{css,scss}'",
      "scss-lint-fix" => "stylelint '**/*.{css,scss}' --fix"
    })
  }
end

append_to_file! "bin/ci-run" do
  <<~ESLINT

    echo "* ******************************************************"
    echo "* Running JS linting"
    echo "* ******************************************************"
    #{package_json.manager.native_run_command("js-lint").join(" ")}
  ESLINT
end

append_to_file! "bin/ci-run" do
  <<~PRETTIER

    echo "* ******************************************************"
    echo "* Running JS linting"
    echo "* ******************************************************"
    #{package_json.manager.native_run_command("format-check").join(" ")}
  PRETTIER
end

# SCSS Linting
add_js_dependencies %w[
  postcss
  stylelint
  stylelint-scss
  stylelint-config-recommended-scss
], type: :dev
copy_file "variants/frontend-base/.stylelintrc.js", ".stylelintrc.js"
template "variants/frontend-base/.stylelintignore.tt", ".stylelintignore"

append_to_file! "bin/ci-run" do
  <<~SASSLINT

    echo "* ******************************************************"
    echo "* Running SCSS linting"
    echo "* ******************************************************"
    #{package_json.manager.native_run_command("scss-lint").join(" ")}
  SASSLINT
end
