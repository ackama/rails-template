source_paths.unshift(File.dirname(__FILE__))

installed_jest_major_version = JSON.parse(File.read("node_modules/jest/package.json")).fetch("version").split(".").first

yarn_add_dev_dependencies [
  "@types/jest@#{installed_jest_major_version}",
  "@jest/types@#{installed_jest_major_version}",
  "ts-jest@#{installed_jest_major_version}",
  "ts-node"
]

copy_file ".eslintrc.js", force: true

remove_file "jest.config.js", force: true
copy_file "jest.config.ts"

copy_file "babel.config.js", force: true

package_json = JSON.parse(File.read("./package.json"))

# we've replaced this with a babel.config.js
package_json.delete "babel"

File.write("./package.json", JSON.generate(package_json))

remove_file "app/frontend/stimulus/controllers/hello_controller.js", force: true
copy_file "app/frontend/stimulus/controllers/hello_controller.ts"

remove_file "app/frontend/stimulus/controllers/add_class_controller.js", force: true
copy_file "app/frontend/stimulus/controllers/add_class_controller.ts"

rename_js_file_to_ts "app/frontend/test/setupExpectEachTestHasAssertions"
rename_js_file_to_ts "app/frontend/test/stimulus/controllers/add_class_controller.test"
