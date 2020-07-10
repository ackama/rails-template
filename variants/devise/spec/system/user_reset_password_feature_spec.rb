require "rails_helper"

RSpec.describe "Users can reset passwords", type: :system do
  describe "accessibility" do
    before { visit new_user_password_path }

    it_behaves_like "an accessible page"
  end

  describe "reset password flow" do
    let(:email_of_existing_user) { "miles.obrien@transporterrm3.enterprise.uss" }
    let(:email_of_unknown_user) { "miles.obrien@deepspacenine.station" }
    let(:valid_password) { "aaaabbbbccccdddd" }

    before { visit new_user_session_path }

    context "with existing users" do
      before do
        FactoryBot.create(:user, email: email_of_existing_user, password: valid_password)
      end

      it "existing users can reset their passwords from the sign-in page" do
        click_link "Forgot your password?"
        fill_in "Email", with: email_of_existing_user
        click_button "Send me reset password instructions"

        # we expect to be redirected to the sign-in page ...
        expect(page).to have_current_path(new_user_session_path, ignore_query: true)
        # ...with a helpful flash message
        expect(page).to have_text("If your email address exists in our database, you will receive a password recovery")

        email = ActionMailer::Base.deliveries.first

        # we expect the user who triggered the reset to be sent an email ...
        expect(email.recipients.first).to eq(email_of_existing_user)
        # ... which contains details about the password reset
        expect(email.body.to_s).to match(/Someone has requested a link to change your password/)
      end
    end

    context "with unknown users" do
      it "unknown users get an error when they try to reset a password" do
        click_link "Forgot your password?"
        fill_in "Email", with: email_of_unknown_user
        click_button "Send me reset password instructions"

        # we expect to be redirected to the user sign-in page ...
        expect(page).to have_current_path(new_user_session_path, ignore_query: true)
        # ... with a helpful flash message
        expect(page).to have_text("If your email address exists in our database, you will receive a password recovery")
      end
    end
  end
end
