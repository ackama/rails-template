set -e

TEMPLATE=$PWD/template.rb
ROOT=$PWD
gem install rails --no-document

mkdir -p template-test/dummy 

# Basic run
VARIANT="${VARIANT:-basic}"
rm -rf template-test/dummy/$VARIANT
cd template-test/dummy

rails new $VARIANT -d postgresql -m $TEMPLATE <<OPTIONS
$GENERATOR_INPUT
OPTIONS

cd $ROOT && bash template-test/test.sh template-test/dummy/$VARIANT



