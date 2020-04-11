require "rails_helper"

RSpec.describe "Homepage", type: :system do
  before { visit root_path }

  it "rendered page contains both base and application layouts" do
    assert_selector("html>head+body")
    assert_selector("body p")
    assert_match(/Home/, page.title)
  end
end
