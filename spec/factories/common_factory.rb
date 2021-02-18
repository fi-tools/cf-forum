FactoryBot.define do

  factory :user, class: User do
    username { Faker::Internet.username }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end

  factory :author, class: Author do

    association :user, factory: :user

    factory :disavowed_author do
      name { Faker::Internet.username }
      public { false }
    end

    factory :avowed_author do
      public { true }
    end
  end
end