class NodeReadableDescendant < ApplicationRecord
  attr_reader :user_id, :base_id, :id, :parent_id, :distance

  belongs_to :user
  # belongs_to :node

  def readonly?
    true
  end
end
