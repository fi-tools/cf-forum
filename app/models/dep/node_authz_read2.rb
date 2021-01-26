class NodeAuthzRead < ApplicationRecord
    belongs_to :base_node, class_name: "Node"
  end
  