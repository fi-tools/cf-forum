class UserTag < ApplicationRecord
  belongs_to :user, optional: true

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"

  class << self
    def find_global(tag)
      self.where(:tag => tag, :user => nil)
    end

    def table
      arel_table
    end

    def is_system
      # arel_table.project(arel_table[Arel.star]).where(arel_table[:user_id].eq(nil))
      table[:user_id].eq(nil)
    end
  end

  private
end
