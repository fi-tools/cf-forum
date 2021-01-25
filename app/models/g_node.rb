class GNode
  include ActiveGraph::Node

  propery :author_id
  propery :depth
  propery :children

  has_one :parent
end
