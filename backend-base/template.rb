source_paths.unshift(File.dirname(__FILE__))

# The accessibility template brings in the lighthouse and
# lighthouse matcher parts we need to run performance specs
apply "backend-base/accessibility/template.rb"
apply "backend-base/performance/template.rb"