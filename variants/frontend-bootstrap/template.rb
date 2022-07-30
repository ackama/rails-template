source_paths.unshift(File.dirname(__FILE__))

yarn_add_dependencies(["bootstrap", "@popperjs/core"])
run "yarn install"

copy_file "app/frontend/js/bootstrap.js", force: true
insert_into_file "app/frontend/packs/application.js", "import '../js/bootstrap.js';", before: "import '../stylesheets/application.scss';"

copy_file "app/frontend/stylesheets/customized_bootstrap.scss", force: true
prepend_to_file "app/frontend/stylesheets/application.scss" do
  <<~EO_CONTENT
    @import '../stylesheets/customized_bootstrap';
  EO_CONTENT
end

gsub_file "config/initializers/content_security_policy.rb", "policy.img_src     :self", "  policy.img_src     :data, :self", force: true
