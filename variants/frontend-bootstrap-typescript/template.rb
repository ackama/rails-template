source_paths.unshift(File.dirname(__FILE__))

add_js_dependencies %w[@types/bootstrap]

rename_js_file_to_ts "app/frontend/js/bootstrap"

tsconfig_json = JSON.parse(File.read("./tsconfig.json"))
tsconfig_json["compilerOptions"]["types"] << "@types/bootstrap"
File.write("./tsconfig.json", JSON.generate(tsconfig_json))
