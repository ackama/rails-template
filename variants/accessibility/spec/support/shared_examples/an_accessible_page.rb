shared_examples "an accessible page", uses_javascript: true do
  it "with no errors" do
    expect(page).to be_accessible.according_to(:wcag2a, :wcag2aa)
  end

  it "passes a Lighthouse accessibility audit" do
    expect(page).to pass_lighthouse_audit(:accessibility)
  end
end
