##
# The app namespace is for tasks which may be useful both in local development
# and on deployed environments.
#
# If your task will be run in local development only you should choose the `dev`
# namespace (see `dev.rake``)
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
