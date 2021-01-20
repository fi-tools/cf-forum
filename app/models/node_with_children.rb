class NodeWithChildren < ApplicationRecord
  # experimental
  has_one :base_node, class_name: "Node"
  has_many :children, class_name: "Node", foreign_key: "id"
end
