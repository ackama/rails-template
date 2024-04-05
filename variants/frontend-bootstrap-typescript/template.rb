source_paths.unshift(File.dirname(__FILE__))

yarn_add_dependencies %w[@types/bootstrap]

rename_js_file_to_ts "app/frontend/js/bootstrap"
