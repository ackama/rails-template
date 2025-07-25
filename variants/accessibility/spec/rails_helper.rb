insert_into_file! "spec/rails_helper.rb", after: /require "selenium-webdriver"\n/ do
  <<~REQUIRE
    require "lighthouse/matchers/rspec"
    require "axe/rspec"
  REQUIRE
end

insert_into_file! "spec/rails_helper.rb", after: /# Add other Chrome arguments here\n/ do
  <<~OPTIONS
    # Lighthouse Matcher options
    options.add_argument("--remote-debugging-port=9222")
    Lighthouse::Matchers.chrome_flags = %w[headless=new no-sandbox]
  OPTIONS
end
