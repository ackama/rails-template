require "performance_helper"

RSpec.describe "Home page", type: :system do
  before do
    log_in_with_basicauth

    visit root_path
  end

  it_behaves_like "a performant page"
end
