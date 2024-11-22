TERMINAL.puts_header "Installing accessibility checking gems"

insert_into_file! "Gemfile", after: /gem "selenium-webdriver"\n/ do
  <<~GEMS

    gem "lighthouse-matchers"
    gem "axe-matchers"
  GEMS
end

run "bundle install"
