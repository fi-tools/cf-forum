class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :authors
  has_many :user_tags

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"

  has_many :group_associations, class_name: "UserGroup"

  def public_authors
    self.authors.select { |author| author.public }
  end

  def groups
    self.group_associations.collect {|ga| ga.group_name}
  end
end
