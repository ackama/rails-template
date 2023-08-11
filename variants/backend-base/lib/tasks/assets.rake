namespace :assets do
  desc "Ensures that dependencies required to compile assets are installed"
  task install_dependencies: :environment do
    raise if File.exist?("yarn.lock") && !(system "yarn install --frozen-lockfile")
  end
end

Rake::Task["assets:precompile"].enhance ["assets:install_dependencies"]
