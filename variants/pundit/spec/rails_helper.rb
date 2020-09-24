insert_into_file "spec/rails_helper.rb", after: /require "axe\/rspec"\n/ do
  <<-REQUIRE
    require "pundit/rspec"
  REQUIRE
end
