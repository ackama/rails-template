source_paths.unshift(File.dirname(__FILE__))

apply "app/template.rb"
apply "bin/template.rb"
apply "config/template.rb"
apply "doc/template.rb"
apply "lib/template.rb"
apply "public/template.rb"
apply "spec/template.rb"


# The accessibility template brings in the lighthouse and
# lighthouse matcher parts we need to run performance specs
apply "accessibility/template.rb"
apply "performance/template.rb"
