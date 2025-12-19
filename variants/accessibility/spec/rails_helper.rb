insert_into_file! "spec/rails_helper.rb", after: /require "selenium-webdriver"\n/ do
  <<~REQUIRE
    require "lighthouse/matchers/rspec"
    require "axe-rspec"
  REQUIRE
end

insert_into_file! "spec/rails_helper.rb", before: /# Add other Chrome arguments here\n/ do
  <<~OPTIONS
    # have lighthouse use the instance of Chrome launched by Capybara, rather than
    # starting its own instance - this is important as otherwise setup work such
    # signing in as a user to access authenticated pages won't work properly
    options.add_argument("--remote-debugging-port=9222")
    Lighthouse::Matchers.remote_debugging_port = 9222
    Lighthouse::Matchers.results_directory = Rails.root.join("tmp/lighthouse")
  OPTIONS
end
