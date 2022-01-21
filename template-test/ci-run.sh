set -e

TEMPLATE=$PWD/template.rb
ROOT=$PWD
gem install rails --no-document

mkdir -p template-test/dummy

# Basic run
VARIANT="${VARIANT:-basic}"
APP_NAME="${VARIANT}-test-app"

rm -rf template-test/dummy/$APP_NAME
mkdir -p template-test/dummy/$APP_NAME

# otherwise rails webpacker:install initiates yarn init and that overrides these yarn.lock package.json files 
# exist under the root directory instead of creating new ones under template-test/dummy/$APP_NAME
cp yarn.lock package.json template-test/dummy/$APP_NAME

cd template-test/dummy

echo -e $GENERATOR_INPUT | RACK_ENV=development RAILS_ENV=development rails new $APP_NAME -d postgresql -m $TEMPLATE \
--skip_javascript

cd $ROOT && bash template-test/test.sh template-test/dummy/$APP_NAME



