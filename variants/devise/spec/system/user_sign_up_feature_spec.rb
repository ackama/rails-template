require "rails_helper"

RSpec.describe "User sign-up", type: :system do
  describe "accessibility" do
    before { visit new_user_registration_path }
    it_behaves_like "an accessible page"
  end

  let(:valid_email) { "miles.obrien@transporterrm3.enterprise.uss" }
  let(:invalid_email) { "miles.obrien@" }
  let(:valid_password) { "aaaabbbbccccdddd" }
  let(:too_short_password) { "aabbcc" }

  before { visit new_user_registration_path }

  it "Users can sign-up" do
    # when we sign up with valid credentials
    fill_in "Email", with: valid_email
    fill_in "Password", with: valid_password
    fill_in "Password confirmation", with: valid_password
    click_button "Sign up"

    # we expect to be redirected to the home page ...
    expect(page.current_path).to eq(root_path)
    # ... with a helpful flash message
    expect(page).to have_text("You have signed up successfully")
    # and to be already signed in
    expect(page).to have_text("You are Signed in")
  end

  describe "email address validation" do
    it "email addresses are validated" do
      # when we sign up with an invalid email address
      fill_in "Email", with: invalid_email
      fill_in "Password", with: valid_password
      fill_in "Password confirmation", with: valid_password
      click_button "Sign up"

      # we expect to now be on the user registration page ...
      expect(page.current_path).to eq(user_registration_path)
      # ... with a helpful flash message
      expect(page).to have_text("Email is invalid")
    end
  end

  describe "password validation" do
    it "users are informed about the password length requirements" do
      # we expect the sign-in page to dispaly a message about password requirements
      expect(page).to have_text("Password (16 characters minimum)")
    end

    it "passwords are validated for length" do
      # when we sign up with a password that is too short
      fill_in "Email", with: valid_email
      fill_in "Password", with: too_short_password
      fill_in "Password confirmation", with: too_short_password
      click_button "Sign up"

      # we expect to now be on the user registration page ...
      expect(page.current_path).to eq(user_registration_path)
      # ... with a helpful flash message
      expect(page).to have_text("Password is too short (minimum is 16 characters)")
    end
  end
end
