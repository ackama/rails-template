##
# This file is executed in a context where
#
#   self.class = Rails::Generators::AppGenerator
#
# which makes some important methods available to us e.g.
#
# * source_paths
# * options


source_paths.unshift(File.dirname(__FILE__))

# We must invoke the code in other template files with #apply instead of
# `require_relative` so that the file is also executed in the context of a
# Rails::Generators::AppGenerator instance
apply "variants/backend-base/template.rb"
