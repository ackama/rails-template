##
# The dev namespace is for tasks which are intended for local development only.
#
# If your tasks are safe and could be useful to run in a deployed environment,
# you should use the `app` namespace (in `app.rake`) instead

##
# WARNING: Wrap `require` for development only gems in an environment check
#
# Gems in the test and development groups are not installed on production
# environments. Rake parses all rake task files before running any task.
# Together these behaviours mean that if you require a development only gem at
# the top level of this file then **all rake tasks will fail to run in staging
# and production**.
#
# If you need to require a gem which will not be available in production, wrap
# it in an environment check e.g.
#
#   require 'my-gem' if Rails.env.development?
#   require 'aws-sdk-ec2' if Rails.env.development?

namespace :dev do
  # desc "Increase developer happiness"
  # task example: :environment do
  # end
end
