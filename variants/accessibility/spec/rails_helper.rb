insert_into_file "spec/rails_helper.rb", after: /require "selenium-webdriver"\n/ do
  <<-REQUIRE.strip_heredoc
    require "lighthouse/matchers/rspec"
    require "axe/rspec"
  REQUIRE
end