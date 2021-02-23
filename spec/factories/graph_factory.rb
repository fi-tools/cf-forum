FactoryBot.define do

  factory :node, class: Node do

    trait :with_parent do
      association :parent, factory: :node
    end

    trait :with_content do
      content_versions { [association(:content)]}
    end

    factory :node_with_direct_children do
      transient do
        direct_children_count { 1 }
      end

      direct_children do
        Array.new(direct_children_count) { association(:node, parent: instance)}
      end
    end
  end

  factory :content, class: ContentVersion do
    author
    node
  end

  factory :user_tag, class: UserTag do
    tag { Faker::Internet.slug }

    identified
    without_anchoring_tags
    without_targeting_tags

    trait :identified do
      user
    end

    trait :system do
      user { nil }
    end

    trait :without_anchoring_tags do
      anchoring_tags { [] }
    end

    trait :without_targeting_tags do
      targeting_tags { [] }
    end

    trait :with_anchoring_tags do
      anchoring_tags { [association(:tag, :user_tag_anchored)]}
    end

    trait :with_targeting_tags do
      targeting_tags { [association(:tag, :user_tag_anchored)]}
    end
  end

  factory :tag, class: TagDecl do
    user
    tag { Faker::Internet.slug }

    node_targeted
    node_anchored

    trait :node_targeted do
      association :target, factory: :node
    end

    trait :node_anchored do
      association :anchored, factory: :node
    end

    trait :user_tag_targeted do
      association :target, factory: :user_tag
    end

    trait :user_tag_anchored do
      association :anchored, factory: :user_tag
    end

  end

end