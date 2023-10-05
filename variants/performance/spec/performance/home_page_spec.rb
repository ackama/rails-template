require "performance_helper"

RSpec.describe "Home page", type: :system do
  before { visit root_path }

  it_behaves_like "a performant page"
end
