source_paths.unshift(File.dirname(__FILE__))

apply "spec/template.rb"
# The accessibility template brings in the lighthouse and
# lighthouse matcher parts we need to run performance specs
apply "accessibility/template.rb"
apply "performance/template.rb"