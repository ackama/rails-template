source_paths.unshift(File.dirname(__FILE__))

add_js_dependencies(["bootstrap", "@popperjs/core"])

copy_file "app/frontend/js/bootstrap.js", force: true
insert_into_file! "app/frontend/packs/application.js", "import '../js/bootstrap';", before: 'import "../stylesheets/application.scss";'

copy_file "app/frontend/stylesheets/customized_bootstrap.scss", force: true
append_to_file! "app/frontend/stylesheets/application.scss" do
  <<~EO_CONTENT

    // We use @import because Bootstrap will not support @use until v6. See
    // https://github.com/twbs/bootstrap/issues/30025#issuecomment-574825600 Our own
    // SCSS files should use @use. Webpack requires that all `@use` be first in a
    // file which conflicts with the stylelint no-invalid-position-at-import-rule`
    // rule so we disable it for this line.
    @import "../stylesheets/customized_bootstrap"; // stylelint-disable-line no-invalid-position-at-import-rule -- See above
  EO_CONTENT
end

gsub_file! "config/initializers/content_security_policy.rb", "policy.img_src     :self", "  policy.img_src     :data, :self", force: true
