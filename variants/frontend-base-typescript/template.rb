source_paths.unshift(File.dirname(__FILE__))

remove_file "app/frontend/packs/hello_typescript.ts"

types_packages = %w[
  rails__actioncable
  rails__activestorage
  rails__ujs
  turbolinks
  dotenv-webpack
  webpack-env
  eslint
  babel__core
].map { |name| "@types/#{name}" }

yarn_add_dependencies types_packages + %w[@babel/preset-typescript typescript]
yarn_add_dev_dependencies %w[@typescript-eslint/parser @typescript-eslint/eslint-plugin]

run "yarn install"

%w[
  app/frontend/packs/application
].each do |file|
  copy_file "#{destination_root}/#{file}.js", "#{file}.ts"
  remove_file "#{file}.js"
end

copy_file "tsconfig.json", force: true
copy_file ".eslintrc.js", force: true
copy_file "types.d.ts", force: true

gsub_file(
  "app/frontend/packs/application.ts",
  "process.env.SENTRY_ENV || process.env.RAILS_ENV",
  "process.env.SENTRY_ENV ?? process.env.RAILS_ENV"
)

js_load_images_chunk = <<~EO_JS_ENABLE_IMAGES
  const images = require.context('../images', true);
  // eslint-disable-next-line no-unused-vars
  const imagePath = name => images(name, true);
EO_JS_ENABLE_IMAGES
ts_load_images_chunk = <<~EO_TS_ENABLE_IMAGES
  const images = require.context('../images', true);
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const imagePath = (name: string): string => {
    return String(images(name));
  };
EO_TS_ENABLE_IMAGES
gsub_file("app/frontend/packs/application.ts", js_load_images_chunk, ts_load_images_chunk, force: true)

package_json = JSON.parse(File.read("./package.json"))
package_json["scripts"]["typecheck"] = "tsc -p . --noEmit"
File.write("./package.json", JSON.generate(package_json))

append_to_file "bin/ci-run" do
  <<~TYPECHECK

    echo "* ******************************************************"
    echo "* Running Typechecking"
    echo "* ******************************************************"
    yarn run typecheck
  TYPECHECK
end
