set -e

TEMPLATE=$PWD/template.rb
ROOT=$PWD
gem install rails --no-document

mkdir -p template-test/dummy

# Basic run
VARIANT="${VARIANT:-basic}"
rm -rf template-test/dummy/$VARIANT
cd template-test/dummy

echo -e $GENERATOR_INPUT | RACK_ENV=development RAILS_ENV=development rails new $VARIANT -d postgresql -m $TEMPLATE

cd $ROOT && bash template-test/test.sh template-test/dummy/$VARIANT



