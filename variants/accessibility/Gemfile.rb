insert_into_file! "Gemfile", after: /gem "selenium-webdriver"\n/ do
  <<~GEMS

    gem "lighthouse-matchers"
    gem "axe-core-rspec"
  GEMS
end

run "bundle install"
