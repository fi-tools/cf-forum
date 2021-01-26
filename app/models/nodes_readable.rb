class NodesReadable < ApplicationRecord
  attr_reader :node_id, :user_id, :node_groups, :user_groups

  def readonly?
    true
  end

  class << self
    def by(user)
    end
  end
end
