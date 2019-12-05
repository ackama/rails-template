source_paths.unshift(File.dirname(__FILE__))

run "mv app/assets app/frontend"
run "mkdir app/assets"
run "mv app/frontend/config app/assets/config"

run "mv app/javascript/* app/frontend"
run "rm -rf app/javascript"
apply "config/template.rb"
apply "app/template.rb"

# SASS Linting
run "yarn add --dev sass-lint"
copy_file "bin/sass-lint"
chmod "bin/sass-lint", "+x"
copy_file "sass-lint.yml", ".sass-lint.yml"
append_to_file "bin/ci-test-pipeline-1" do
  <<~SASSLINT
  
  echo "* ******************************************************"
  echo "* Running SCSS linting"
  echo "* ******************************************************"
  ./bin/sass-lint
  SASSLINT
end
