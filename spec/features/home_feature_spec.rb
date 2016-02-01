require "rails_helper"

RSpec.describe "Home page", type: :feature do
  before { visit "/" }
  it { expect(page).to have_content "home/index.html.erb" }
end
