insert_into_file "spec/rails_helper.rb", after: /require "selenium-webdriver"\n/ do
  <<-REQUIRE.strip_heredoc
    require "lighthouse/matchers/rspec"
    require "axe/rspec"
  REQUIRE
end

insert_into_file "spec/rails_helper.rb", after: /# Add other Chrome arguments here\n/ do
  <<-OPTIONS.strip_heredoc
    # Lighthouse Matcher options
    options.add_argument("--remote-debugging-port=9222")
    Lighthouse::Matchers.chrome_flags = %w[headless no-sandbox]
  OPTIONS
end