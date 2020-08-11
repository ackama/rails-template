source_paths.unshift(File.dirname(__FILE__))

# Generic lighthouse and lighthouse-matchers setup
apply "Gemfile.rb"
apply "spec/rails_helper.rb"
run "yarn add --dev lighthouse"

# Accessibility specific test setup and example
apply "accessibility/template.rb"
# Performance specific test setup and example
apply "performance/template.rb"
