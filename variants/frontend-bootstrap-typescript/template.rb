source_paths.unshift(File.dirname(__FILE__))

yarn_add_dependencies %w[@types/bootstrap]
yarn_add_dev_dependencies %w[@typescript-eslint/parser @typescript-eslint/eslint-plugin]

run "yarn install"

%w[
  app/frontend/js/bootstrap
].each do |file|
  copy_file "#{destination_root}/#{file}.js", "#{file}.ts"
  remove_file "#{file}.js"
end
