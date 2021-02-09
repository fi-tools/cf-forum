class ContentVersion < ApplicationRecord
  # belongs_to :node, optional: true
  belongs_to :author
  belongs_to :node

  # belongs_to :parent, class_name: "ContentVersion", optional: true

  before_create :nilify_title

  def nilify_title
    if self.title&.length == 0
      self.title = nil
    end
  end
end
