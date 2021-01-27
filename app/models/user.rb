class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :authors
  has_many :user_tags

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"
  has_many :anchored_usertags, through: :anchoring_tags, source: :target, source_type: "UserTag"

  has_many :anchoring_system_tags, as: :anchored, class_name: "SystemTagDecl"
  has_many :anchored_system_tags, through: :anchoring_system_tags, source: :target, source_type: "UserTag"

  has_one :users_group

  after_create :create_user_author, :refresh_users_groups

  def create_user_author
    self.authors << Author.create(user: self)
  end

  def refresh_users_groups
    UsersGroup.refresh
  end

  def public_authors
    self.authors.select { |author| author.public }
  end

  def groups
    self.users_group.groups
  end

  def groups_arel
    throw "deprecated? replaced with user_groups view"
    uts = UserTag.table
    tds = TagDecl.table
    User.arel_table.join(tds)
      .on(tds[:anchored_id].eq(id).and(tds[:anchored_type].eq(User.name)).and(tds[:tag].eq(Authz.userInGroup)))
      .join(uts)
      .on(tds[:target_id].eq(uts[:id]))
      .where(UserTag.is_system.and(TagDecl.is_system.and(tds[:target_type].eq(UserTag.name))))
      .project(uts[:tag].as("group_name"))
  end

  class << self
    def from_id_or_nil(id)
      unless id.nil?
        User.from(id)
      end
    end
  end
end
