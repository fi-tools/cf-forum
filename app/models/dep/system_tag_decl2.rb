class SystemTagDecl < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :target, polymorphic: true
  belongs_to :anchored, polymorphic: true

  self.primary_key = :id

  # has_many :system_user_tags, as: :target, class_name: "SystemUserTag"
  # has_many :nodes, as: :anchor

end
