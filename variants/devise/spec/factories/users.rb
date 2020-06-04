FactoryBot.define do
  factory :user do
    email { "user-#{SecureRandom.hex(5)}@example.com" }
    password { "aaaabbbbccccdddd" }
    password_confirmation { password }
  end
end
