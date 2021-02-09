class NodeAncestorsIncr < ApplicationRecord
  attr_reader :base_id, :node_id, :distance

  def readonly?
    true
  end
end
