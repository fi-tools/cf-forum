class UserGroup < ApplicationRecord
  belongs_to :user, optional: true

  self.primary_key = :id
end
