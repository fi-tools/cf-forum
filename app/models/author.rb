class AuthorValidator < ActiveModel::Validator
  def validate(author)
    if !author.name.nil? && author.name.length == 0
      author.errors.add :base, "Author name cannot be length 0"
    end
  end
end

class Author < ApplicationRecord
  # validates :name, :public?

  belongs_to :user

  has_many :nodes
  has_many :posts, class_name: "Node"
  has_many :content_versions

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"

  validates_with AuthorValidator

  def formatted_name
    if self.name.nil? || self.name.length == 0
      puts self.to_json
      if self.public
        return "u/#{self.user.username}"
      else
        return "Anonymous"
      end
    end
    "a/#{self.name}"
  end
end
