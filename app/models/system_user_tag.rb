class SystemUserTag < ApplicationRecord
  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"

  has_many :targeting_system_tags, as: :target, class_name: "SystemTagDecl"
end
