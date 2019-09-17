source_paths.unshift(File.dirname(__FILE__))

run "yarn add foundation-sites jquery"
run "yarn add --dev font-awesome"

directory "app/frontend/foundation"
empty_directory_with_keep_file "app/frontend/images"

append_to_file "app/frontend/packs/application.js" do
  <<~JS
    require.context('../images', true);
    import "foundation";
  JS
end