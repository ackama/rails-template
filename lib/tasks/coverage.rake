namespace :test do
  task coverage: :environment do
    require "simplecov"
    Rake::Task["test"].execute
  end
end
