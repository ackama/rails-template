source_paths.unshift(File.dirname(__FILE__))

# Renames a JavaScript file that ends with ".js" to ".ts"
#
# @param [String] file
def rename_js_file_to_ts(file)
  copy_file "#{destination_root}/#{file}.js", "#{file}.ts"
  remove_file "#{file}.js"
end

remove_file "app/frontend/packs/hello_typescript.ts"

types_packages = %w[
  rails__actioncable
  rails__activestorage
  rails__ujs
  turbolinks
  dotenv-webpack
  webpack-env
  eslint@8
  babel__core
  node@18
].map { |name| "@types/#{name}" }

yarn_add_dependencies types_packages + %w[@babel/preset-typescript typescript]
yarn_add_dev_dependencies %w[
  @stylistic/eslint-plugin-ts@3
  @typescript-eslint/eslint-plugin
  @typescript-eslint/parser
]

rename_js_file_to_ts "app/frontend/packs/application"

copy_file "tsconfig.json", force: true
copy_file "eslint.config.js", force: true
copy_file "types.d.ts", force: true

gsub_file!(
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
gsub_file!("app/frontend/packs/application.ts", js_load_images_chunk, ts_load_images_chunk, force: true)

package_json.merge! do |pj|
  {
    "scripts" => pj.fetch("scripts", {}).merge({
      "typecheck" => "tsc -p . --noEmit"
    })
  }
end

append_to_file! "bin/ci-run" do
  <<~TYPECHECK

    echo "* ******************************************************"
    echo "* Running Typechecking"
    echo "* ******************************************************"
    #{package_json.manager.native_run_command("typecheck").join(" ")}
  TYPECHECK
end
