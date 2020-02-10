require "rails_helper"

RSpec.describe "HTTP Basic Auth Middleware", type: :request do
  context "with HTTP Basic Auth enabled" do
    let(:username) { "Miles O'Brien" }
    let(:password) { "Ow me shoulder again!" }
    let(:http_basic_auth_header) do
      {
        "Authorization" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
      }
    end

    around(:each) do |example|
      ENV["HTTP_BASIC_AUTH_USERNAME"] = username
      ENV["HTTP_BASIC_AUTH_PASSWORD"] = password
      example.run
      ENV["HTTP_BASIC_AUTH_USERNAME"] = nil
      ENV["HTTP_BASIC_AUTH_PASSWORD"] = nil
    end

    context "when the request provides valid HTTP basic auth credentials" do
      it "rendered page contains both base and application layouts" do
        get root_path, headers: http_basic_auth_header

        expect(response.status).to eq(200)
        expect(response.body).to include("Find me in app")
      end
    end

    context "when the request does not provide a valid HTTP basic auth credentials" do
      it "rendered page contains both base and application layouts" do
        get root_path, headers: {}

        expect(response.headers["WWW-Authenticate"]).to eq('Basic realm=""')
        expect(response.status).to eq(401)
      end
    end
  end
end