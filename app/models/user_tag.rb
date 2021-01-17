class UserTag < ApplicationRecord
  belongs_to :user, optional: true

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"

  class << self
    def find_global(tag)
      self.where(:tag => tag, :user => nil)
    end
  end
end
