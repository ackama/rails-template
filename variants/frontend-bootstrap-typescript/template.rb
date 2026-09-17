source_paths.unshift(File.dirname(__FILE__))

add_js_dependencies %w[@types/bootstrap]

rename_js_file_to_ts "app/frontend/js/bootstrap"
