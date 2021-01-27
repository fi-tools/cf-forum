class NodesReadable < ApplicationRecord
  attr_reader :node_id, :user_id, :node_groups, :user_groups

  belongs_to :node
  belongs_to :user

  self.primary_key = :node_id

  def readonly?
    true
  end

  class << self
    def by(user)
      NodesReadable.where(user_id: user.id)
    end
  end
end
