append_to_file! "Rakefile" do
  <<~RUBY

    begin
      require "rubocop/rake_task"
      RuboCop::RakeTask.new
      task default: %w[spec spec:system rubocop]
    rescue LoadError # rubocop:disable Lint/SuppressedException
    end
  RUBY
end
