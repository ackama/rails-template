FactoryBot.define do
  factory :user do
    email { "user-#{SecureRandom.hex(5)}@example.com" }

    # User#password is a virtual attribute (i.e. it is not stored direclty in
    # the DB) so we need call the User#password= method after building the user
    # to set it.
    after(:build) { |u| u.password = "aabbccdd" }
  end
end
