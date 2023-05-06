source_paths.unshift(File.dirname(__FILE__))

installed_jest_major_version = JSON.parse(File.read("node_modules/jest/package.json")).fetch("version").split(".").first

run "yarn remove prop-types"
yarn_add_dependencies %w[@types/react @types/react-dom]
yarn_add_dev_dependencies [
  "@jest/types@#{installed_jest_major_version}",
  "ts-jest@#{installed_jest_major_version}",
  "ts-node"
]
run "yarn install"

rename_js_file_to_ts "app/frontend/packs/server_rendering"

copy_file "tsconfig.json", force: true
copy_file ".eslintrc.js", force: true
copy_file "babel.config.js", force: true

remove_file "jest.config.js"
copy_file "jest.config.ts"

# example files
remove_file "app/frontend/components/HelloWorld.jsx", force: true
copy_file "app/frontend/components/HelloWorld.tsx", force: true
gsub_file(
  "app/views/home/index.html.erb",
  'react_component("HelloWorld", { greeting: "Hello from react-rails." })',
  'react_component("home/index")'
)

tsconfig_json = JSON.parse(File.read("./tsconfig.json"))
tsconfig_json["compilerOptions"]["jsx"] = "react"
File.write("./tsconfig.json", JSON.generate(tsconfig_json))

append_to_file "types.d.ts" do
  <<~TYPES
    declare module 'react_ujs' {
      import RequireContext = __WebpackModuleApi.RequireContext;

      interface ReactRailsUJS {
        useContext(context: RequireContext): void;
      }

      const ReactRailsUJS: ReactRailsUJS;

      export default ReactRailsUJS;
    }
  TYPES
end

remove_dir "app/frontend/test"
directory "app/frontend/test"
