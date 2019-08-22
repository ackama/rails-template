set -e

TEMPLATE=$PWD/template.rb
ROOT=$PWD
gem install rails --no-document

# Basic run
TEST_NAME="basic"
rm -rf template-test/dummy/$TEST_NAME
cd template-test/dummy

# Pipe newlines to `rails new` to accept defaults
yes '<enter>' | rails new $TEST_NAME -m $TEMPLATE -d postgresql 

cd $ROOT

bash template-test/test.sh template-test/dummy/$TEST_NAME

