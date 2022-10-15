require "rails_helper"

RSpec.describe "Content-Security-Policy HTTP Header", type: :request do
  context "when the application receives a request" do
    before do
      get root_path
    end

    it "returns a Content-Security-Policy header as part of the response" do
      expect(response.headers["Content-Security-Policy"]).not_to be_nil
    end
  end
end
