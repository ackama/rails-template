set -e

TEMPLATE=$PWD/template.rb
ROOT=$PWD
gem install rails --no-document

mkdir -p template-test/dummy 

# Basic run
TEST_NAME="basic"
rm -rf template-test/dummy/$TEST_NAME
cd template-test/dummy

# Prompts:
#   * production hostname
#   * staging hostname
#   * no, don't overwrite webpacker.yml with Rails' version
rails new $TEST_NAME -d postgresql -m $TEMPLATE <<OPTIONS
example.com
staging.example.com
n
OPTIONS

cd $ROOT && bash template-test/test.sh template-test/dummy/$TEST_NAME

cd template-test/dummy

# Foundation variant
# Prompts:
#   * production hostname
#   * staging hostname
#   * yes, set up foundation
#   * no, don't overwrite webpacker.yml with Rails' version
TEST_NAME="foundation"
rails new $TEST_NAME -d postgresql -m $TEMPLATE <<OPTIONS
example.com
staging.example.com
y
n
OPTIONS

cd $ROOT && bash template-test/test.sh template-test/dummy/$TEST_NAME



