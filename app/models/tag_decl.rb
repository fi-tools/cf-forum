class TagDecl < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :target, polymorphic: true
  belongs_to :anchored, polymorphic: true

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"
end
