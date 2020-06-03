require "rails_helper"

RSpec.describe User, type: :model do
  describe "User Factory" do
    it "creates valid users" do
      expect(FactoryBot.build(:user)).to be_valid
    end
  end

  it "is valid when created with valid attributes" do
    valid_password = "aabbccdd"
    user = User.new(email: "picard@uss1701d.com",
                    password: valid_password,
                    password_confirmation: valid_password)
    expect(user).to be_valid
  end
end
