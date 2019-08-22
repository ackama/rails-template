set -e

TEMPLATE=$PWD/template.rb
ROOT=$PWD
gem install rails --no-document

# Basic run
TEST_NAME="basic"
TEST_PATH="template-test/dummy/$TEST_NAME"
rm -rf $TEST_PATH
cd "$TEST_PATH/.."

# Pipe newlines to `rails new` to accept defaults
yes '<enter>' | rails new $TEST_NAME -m $TEMPLATE -d postgresql 

cd $ROOT

bash template-test/test.sh $TEST_PATH

