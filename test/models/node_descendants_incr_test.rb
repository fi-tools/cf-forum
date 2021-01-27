require "test_helper"
# require "minitest/byebug" if ENV["DEBUG"]

class NodeDescendantsIncrTest < ActiveSupport::TestCase
  # test disabled bc node_descendants_incr disabled
  # setup do
  #   pw = "hunter2"
  #   admin_email = "#{SecureRandom.hex(12)}@xk.io"
  #   admin = User.create! :username => SecureRandom.hex(12), :email => admin_email, :password => pw
  #   @admin_author = Author.find_or_create_by! :user => admin, :name => SecureRandom.hex(12), :public => true

  #   @nodes = []
  #   @root = create_node(0, "root", nil, author: @admin_author)
  #   @nodes << @root
  #   @nodes << create_node(nil, "reply1", @root.id, author: @admin_author)
  #   @nodes << create_node(nil, "reply2", @root.id, author: @admin_author)
  # end

  # test "node_descendants_incr has records with base_id=node_id for each node" do
  #   total_nodes = Node.all.count
  #   t = NodeDescendantsIncr.arel_table
  #   # all_ndi = NodeDescendantsIncr.all
  #   # Rails::logger.debug all_ndi.inspect
  #   assert_equal @nodes.count, total_nodes, "sanity check nodes count in db -- is only those we've set up"
  #   assert_equal 5, NodeDescendantsIncr.all.count, "should have 5 total records"
  #   assert_equal total_nodes, NodeDescendantsIncr.where(t[:base_id].eq(@root.id)).count, "root node should have `Node.all.count` descendants"
  #   assert_equal total_nodes, NodeDescendantsIncr.where(t[:base_id].eq(t[:node_id])).count, "each node should have 1 record for base_id=node_id"
  #   assert_equal total_nodes, NodeDescendantsIncr.where(t[:base_id].eq(t[:node_id]).and(t[:distance].eq(0))).count, "all base_id=node_id records should have distance=0"
  # end
end
