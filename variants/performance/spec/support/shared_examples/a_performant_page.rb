shared_examples "a performant page", uses_javascript: true do
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

    it "with a minimum passing score of 95" do
      expect(page).to pass_lighthouse_audit(:performance, score: 95)
    end
  end
end
