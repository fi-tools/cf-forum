FactoryBot.define do

  sequence(:unique_readable_name) do |n|
    "#{Faker::Internet.username}#{n}"
  end

  factory :user, class: User do
    username { generate(:unique_readable_name) }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end

  factory :author, class: Author do

    association :user, factory: :user

    factory :disavowed_author do
      name { generate(:unique_readable_name) }
      public { false }
    end

    factory :avowed_author do
      public { true }
    end
  end
end