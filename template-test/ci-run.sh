set -e

TEMPLATE=$PWD/template.rb
ROOT=$PWD
gem install rails --no-document

mkdir -p template-test/dummy

# Basic run
VARIANT="${VARIANT:-basic}"
APP_NAME="${VARIANT}-test-app"

rm -rf template-test/dummy/$APP_NAME
cd template-test/dummy

echo -e $GENERATOR_INPUT | RACK_ENV=development RAILS_ENV=development rails new $APP_NAME -d postgresql -m $TEMPLATE

# Run overcommit
cd $APP_NAME
# gem install overcommit --no-document
# overcommit -r

cd $ROOT && bash template-test/test.sh template-test/dummy/$APP_NAME



