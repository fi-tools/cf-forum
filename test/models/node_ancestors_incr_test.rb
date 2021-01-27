require "test_helper"
# require "minitest/byebug" if ENV["DEBUG"]

class NodeAncestorsIncrTest < ActiveSupport::TestCase
  setup do
    @user, @author = gen_test_user_and_author

    @nodes = []
    @root = create_node(0, "root", nil, author: @author)
    @nodes << @root
    @nodes << create_node(nil, "reply1", @root.id, author: @author)
    @nodes << create_node(nil, "reply2", @root, author: @author)
  end

  test "node_ancestors_incr has records with base_id=node_id for each node" do
    total_nodes = Node.all.count
    # triggers = ActiveRecord::Base.connection.execute "SELECT * FROM information_schema.triggers;"
    t = NodeAncestorsIncr.arel_table
    assert_equal @nodes.count, total_nodes, "sanity check nodes count in db -- is only those we've set up"
    assert_equal 5, NodeAncestorsIncr.all.count, "should have 5 total records"
    assert_equal 1, NodeAncestorsIncr.where(t[:base_id].eq(@root.id)).count, "root node should have 1 ancestor"
    assert_equal total_nodes, NodeAncestorsIncr.where(t[:base_id].eq(t[:node_id])).count, "each node should have 1 record for base_id=node_id"
    assert_equal total_nodes, NodeAncestorsIncr.where(t[:base_id].eq(t[:node_id]).and(t[:distance].eq(0))).count, "all base_id=node_id records should have distance=0"
  end
end
