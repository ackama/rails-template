source_paths.unshift(File.dirname(__FILE__))

run "rails webpacker:install:typescript"
remove_file "app/frontend/packs/hello_typescript.ts"

types_packages = %w[
  rails__actioncable
  rails__activestorage
  rails__ujs
  actioncable
  turbolinks
  dotenv-webpack
  postcss-import
  postcss-flexbugs-fixes
  postcss-preset-env
  webpack-env
  eslint
  babel__core
].map { |name| "@types/#{name}" }

run "yarn remove prop-types"
run "yarn add #{types_packages.join " "}"
run "yarn add -D @typescript-eslint/parser @typescript-eslint/eslint-plugin"
run "yarn install"

%w[
  app/frontend/channels/consumer
  app/frontend/channels/index
  app/frontend/packs/application
  app/frontend/packs/server_rendering
].each do |file|
  copy_file "#{destination_root}/#{file}.js", "#{file}.ts"
  remove_file "#{file}.js"
end

copy_file "tsconfig.json", force: true
copy_file ".eslintrc.js", force: true
copy_file "types.d.ts", force: true

gsub_file "app/frontend/channels/index.ts", '_channel\.js', '_channel\.ts'
gsub_file(
  "app/frontend/packs/application.ts",
  "process.env.SENTRY_ENV || process.env.RAILS_ENV",
  "process.env.SENTRY_ENV ?? process.env.RAILS_ENV"
)

babel_config_file = "babel.config.js"

insert_into_file babel_config_file, after: /^'use strict';\n/ do
  <<-JS

/**
 * Guards that `value` is not `false`
 *
 * @param {T | false} value
 *
 * @return {value is T}
 *
 * @template T
 */
const notFalseGuard = value => value !== false;

/** @type {import('@babel/core').ConfigFunction} */
  JS
end

gsub_file babel_config_file, "\nmodule.exports = api => {", "const config = api => {"
gsub_file babel_config_file, "].filter(Boolean)", "].filter(notFalseGuard)"
append_to_file babel_config_file, "\nmodule.exports = config;"

package_json = JSON.parse(File.read("./package.json"))
package_json["scripts"]["typecheck"] = "tsc -p . --noEmit"
File.write("./package.json", JSON.generate(package_json))

# example files
remove_file "app/frontend/components/HelloWorld.jsx", force: true
copy_file "app/frontend/components/home/index.tsx", force: true
copy_file "app/frontend/components/utils/index.ts", force: true
copy_file "app/frontend/components/utils/Form.tsx", force: true
copy_file "app/frontend/components/utils/TextInput.tsx", force: true
gsub_file(
  "app/views/home/index.html.erb",
  'react_component("HelloWorld", { greeting: "Hello from react-rails." })',
  'react_component("home/index")'
)

# we need to re-run these to apply the ts rules
run "yarn run js-lint-fix"
run "yarn run format-fix"
run "yarn run typecheck"

append_to_file "bin/ci-run" do
  <<~TYPECHECK

    echo "* ******************************************************"
    echo "* Running Typechecking"
    echo "* ******************************************************"
    yarn run typecheck
  TYPECHECK
end
