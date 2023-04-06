shared_examples "an accessible page", uses_javascript: true do
  it "with no errors" do
    expect(page).to be_accessible.according_to(:wcag2a, :wcag2aa)
  end

  context "when suppressing basicauth" do
    around do |example|
      original_basic_auth_username = ENV.fetch("HTTP_BASIC_AUTH_USERNAME", nil)
      original_basic_auth_password = ENV.fetch("HTTP_BASIC_AUTH_PASSWORD", nil)
      ENV["HTTP_BASIC_AUTH_USERNAME"] = nil
      ENV["HTTP_BASIC_AUTH_PASSWORD"] = nil
      example.run
      ENV["HTTP_BASIC_AUTH_USERNAME"] = original_basic_auth_username
      ENV["HTTP_BASIC_AUTH_PASSWORD"] = original_basic_auth_password
    end


    it "passes a Lighthouse accessibility audit" do
      expect(page).to pass_lighthouse_audit(:accessibility)
    end
  end
end
