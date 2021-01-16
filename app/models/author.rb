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

  validates_with AuthorValidator

  def formatted_name
    if @name.nil? || @name.length == 0
      if @name.public
        return "u/#{@user.username}"
      else
        return "Anonymous"
      end
    end
    "a/#{@name}"
  end
end
