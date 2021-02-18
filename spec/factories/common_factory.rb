FactoryBot.define do
  factory :user, class: User do
    username { Faker::Internet.username }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end

  factory :public_author, class: Author do
    name { Faker::Name.name }
    public { true }
    user { create(:user) }
  end

  factory :private_author, class: Author do
    name { Faker::Name.name }
    public { false }
    user { create(:user) }
  end
end