require "rails_helper"

RSpec.describe "Session cookies are expired immediately after logout" do
  let(:password) { SecureRandom.hex(16) }

  let(:user) { FactoryBot.create(:user, password:) }

  it "session cookies are invalidated by logging out" do
    # Sign in
    post new_user_session_path, params: { "user[email]" => user.email, "user[password]" => password }

    # When we view a page which requires a signed-in user ...
    get edit_user_registration_path

    # ... then it works.
    expect(response).to have_http_status(:ok)
    expect(response.body).to match(/Edit User/)

    # Save the signed-in user's session cookie
    session_cookie = response.headers["Set-Cookie"]

    # Sign out
    delete destroy_user_session_path

    # When we try to view the same page as before ...
    get edit_user_registration_path

    # ... then we are redirected to the sign-in page
    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to eq(new_user_session_url)

    # When we try to view the private page, this time passing the old session
    # cookie ...
    get edit_user_registration_path, headers: { "Cookie" => session_cookie }

    # ... then we are still redirected to the sign-in page (this demonstrates
    # that session cookies are properly invalidated when a user signs out)
    expect(response).to have_http_status(:found)
    expect(response.headers["Location"]).to eq(new_user_session_url)
  end
end
