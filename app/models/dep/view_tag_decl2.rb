class ViewTagDecl < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :target, polymorphic: true
  belongs_to :anchored, polymorphic: true

  self.primary_key = :id
end
