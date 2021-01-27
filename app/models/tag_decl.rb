class TagDecl < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :target, polymorphic: true
  belongs_to :anchored, polymorphic: true

  # has_many :anchoring_tags, as: :anchored, class_name: self.class.name
  # has_many :targeting_tags, as: :target, class_name: self.class.name

  after_create :refresh_system_tags

  def refresh_system_tags
    SystemTag.refresh
    UsersGroup.refresh
  end

  class << self
    def table
      arel_table
    end

    def is_system
      table[:user_id].eq(nil)
    end

    # returns (id, td_tag, anchored_type, anchored_id, ut_tag)
    def system_tags
      uts = UserTag.table
      tds = TagDecl.table
      tds.join(uts)
        .on(tds[:target_id].eq(uts[:id]))
        .where(UserTag.is_system.and(TagDecl.is_system.and(tds[:target_type].eq(UserTag.name))))
        .project(tds[:id], tds[:tag].as("td_tag"), tds[:anchored_type], tds[:anchored_id], uts[:tag].as("ut_tag"))
    end
  end

  private
end
