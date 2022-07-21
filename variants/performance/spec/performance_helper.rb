require "rails_helper"
require "fileutils"

##
# To get realistic results from the performance specs, we need to pre-compile
# the assets. Pre-compiling assets is slow so we only want to do it:
#
# 1. Once before we run performance specs
# 2. Only when we run performance specs (you don't want to wait for
#    precompilation when running other specs)
#
# Rspec provides the `before(:suite)` hook which runs exactly once before the
# test suite begins so we hijack that to precompile assets.
#
RSpec.configure do |config|
  # Precompiling assets before running specs with js set to true not only helps
  # to speed things up slightly but also creates an environment that we can run
  # performance specs against.  Without this webpacker doesn't zip the js packs
  # and the performance specs show vastly different results to a live
  # environment.
  config.before(:suite) do
    puts "*" * 80
    puts "NOTICE: This Rspec run includes performance tests from spec/performance/"
    puts "NOTICE: We are pre-compiling assets to get realistic results from the performance tests"
    puts "NOTICE: Pre-compilation can take a while ..."

    # Use FileUtils rather than shelling out so that this works on Windows & Unix environments
    FileUtils.rm_rf(Rails.public_path.join("packs-test"))
    system "bundle exec rake assets:precompile"

    puts "*" * 80
  end
end
