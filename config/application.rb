gsub_file "config/application.rb",
          "# config.time_zone = 'Central Time (US & Canada)'",
          "config.time_zone = 'Wellington'"

insert_into_file "config/application.rb", :before => /^  end/ do
  <<-'RUBY'

    # Ensure non-standard paths are eager-loaded in production
    # (these paths are also autoloaded in development mode)
    # config.eager_load_paths += %W(#{config.root}/lib)
  RUBY
end
