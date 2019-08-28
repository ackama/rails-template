set -e

TEMPLATE=$PWD/template.rb
ROOT=$PWD
gem install rails --no-document

mkdir -p template-test/dummy 

# Basic run
TEST_NAME="basic"
rm -rf template-test/dummy/$TEST_NAME
cd template-test/dummy

# Pipe newlines to `rails new` to accept defaults
rails new $TEST_NAME -d postgresql -m $TEMPLATE <<OPTIONS
example.com
staging.example.com
n
OPTIONS

cd $ROOT

bash template-test/test.sh template-test/dummy/$TEST_NAME

