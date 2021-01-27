require "test_helper"

class NodeDescendantsIncrTest < ActiveSupport::TestCase
  setup do
    pw = "hunter2"
    admin_email = "#{SecureRandom.hex(12)}@xk.io"
    admin = User.create! :username => SecureRandom.hex(12), :email => admin_email, :password => pw
    @admin_author = Author.find_or_create_by! :user => admin, :name => SecureRandom.hex(12), :public => true

    @nodes = []
    @root = create_node(0, "root", nil, author: @admin_author)
    @nodes << @root
    @nodes << create_node(nil, "reply1", @root, author: @admin_author)
    @nodes << create_node(nil, "reply2", @root, author: @admin_author)
  end

  test "node_descendants_incr has records with base_id=node_id for each node" do
    total_nodes = Node.all.count
    t = NodeDescendantsIncr.arel_table
    assert_equal @nodes.count, NodeDescendantsIncr.where(t[:base_id].eq(@root.id)).count
    assert_equal total_nodes, NodeDescendantsIncr.where(t[:base_id].eq(t[:node_id])).count
    assert_equal total_nodes, NodeDescendantsIncr.where(t[:base_id].eq(t[:node_id]).and(t[:distance].eq(0))).count
  end
end
