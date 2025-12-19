source_paths.unshift(File.dirname(__FILE__))

add_js_dependencies ["@babel/plugin-transform-typescript"]
add_js_dependencies [
  "@types/jest@#{JEST_MAJOR_VERSION}",
  "ts-node"
], type: :dev

copy_file "eslint.config.js", force: true

remove_file "jest.config.js", force: true
copy_file "jest.config.ts"

copy_file "babel.config.js", force: true

# we've replaced this with a babel.config.js
package_json.delete!("babel")

remove_file "app/frontend/stimulus/controllers/hello_controller.js", force: true
copy_file "app/frontend/stimulus/controllers/hello_controller.ts"

remove_file "app/frontend/stimulus/controllers/add_class_controller.js", force: true
copy_file "app/frontend/stimulus/controllers/add_class_controller.ts"

rename_js_file_to_ts "app/frontend/test/setupJestDomMatchers"
rename_js_file_to_ts "app/frontend/test/setupExpectEachTestHasAssertions"
rename_js_file_to_ts "app/frontend/test/stimulus/controllers/add_class_controller.test"
