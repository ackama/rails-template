##
# The app namespace is for tasks which may be useful both in local development
# and on deployed environments.
#
# if your tasks are intended to only be run in local development, you should
# use the `dev` namespace (in `dev.rake`) instead
#
namespace :app do
  desc "Print (to STDOUT) count of records in DB for each ActiveRecord model"
  task db_stats: :environment do
    # Ensure all classes are loaded if we are in an environment which lazy
    # loads them (e.g. development)
    Rails.application.eager_load!

    ApplicationRecord
      .descendants
      .map(&:to_s)
      .sort
      .each do |model_name|
      puts "#{model_name}: #{model_name.constantize.count} records"
    end
  end
end
