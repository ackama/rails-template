FactoryBot.define do
  factory :user do
    email { "user-#{SecureRandom.hex(5)}@example.com" }
    password { "aabbccdd" }
    password_confirmation { password }
  end
end
