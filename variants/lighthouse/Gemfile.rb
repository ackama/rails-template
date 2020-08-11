insert_into_file "Gemfile", after: /gem "webdrivers"\n/ do
  <<~GEMS

    gem "lighthouse-matchers"
  GEMS
end

run "bundle install"
