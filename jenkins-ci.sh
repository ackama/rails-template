#!/bin/bash
#
# Script used to test this project in Jenkins and continuously deploy the
# development branch. Assumes the Jenkins
# user is using bash and rbenv. YMMV.
#
set -e

# Ensure we are in the project directory
cd $WORKSPACE

# If ruby version is not installed, install it
if ! ruby -v &> /dev/null; then
  rbenv update
  rbenv install `cat .ruby-version`
fi

# Install necessary version of bundler
bundler_version=`ruby -e 'puts $<.read[/BUNDLED WITH\n   (\S+)$/, 1] || "<1.10"' Gemfile.lock`
gem install bundler --conservative --no-document -v $bundler_version

# Set up local config
cp config/database.example.yml config/database.yml
cp example.env .env

bundle install --deployment --retry=3
bundle exec rake db:drop || true
bundle exec rake db:create db:migrate
bundle exec rake db:seed

# Webkit needs an X server in order to render.
# See https://github.com/thoughtbot/capybara-webkit/issues/402
if type xvfb-run; then
  DISABLE_SPRING=1 DISPLAY=localhost:1.0 xvfb-run bundle exec rake test:coverage
else
  DISABLE_SPRING=1 bundle exec rake test:coverage
fi

# Security audits
if bundle show brakeman &> /dev/null; then
  bundle exec brakeman --no-progress
fi
if bundle show bundler-audit &> /dev/null; then
  bundle exec bundle-audit update
  bundle exec bundle-audit -v
fi
