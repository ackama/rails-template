source_paths.unshift(File.dirname(__FILE__))

yarn_add_dependencies %w[@types/bootstrap]
yarn_add_dev_dependencies %w[
  @typescript-eslint/parser@5
  @typescript-eslint/eslint-plugin@5
]

run "yarn install"

rename_js_file_to_ts "app/frontend/js/bootstrap"
