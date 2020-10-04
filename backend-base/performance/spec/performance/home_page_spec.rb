require "performance_helper"

RSpec.feature "Home page", type: :system do
  before { visit root_path }

  it_behaves_like "a performant page"
end
