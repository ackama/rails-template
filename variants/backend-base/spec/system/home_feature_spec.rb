require "rails_helper"

RSpec.describe "Homepage" do
  before { visit root_path }

  it "rendered page contains both base and application layouts" do
    assert_selector("html>head+body")
    assert_selector("body p")
    expect(page.title).to include("Home")
  end
end
