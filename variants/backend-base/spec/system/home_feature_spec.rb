require "rails_helper"

RSpec.describe "Homepage" do
  before do
    log_in_with_basicauth

    visit root_path
  end

  it "rendered page contains both base and application layouts" do
    assert_selector("html>head+body")
    assert_selector("body p")
    expect(page.title).to match(/Home/)
  end
end
