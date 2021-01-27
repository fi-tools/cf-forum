require "test_helper"
# require "minitest/byebug" if ENV["DEBUG"]

class NodeTest < ActiveSupport::TestCase
  include Cff::NodeFaker

  setup do
    test_setup_3_nodes
  end

  test "node record should have accurate n_descendants, n_children, and depth" do
    assert_equal 0, Node.find(@root.id).depth, "root has depth 0"
    assert_equal 2, Node.find(@root.id).n_children, "root cached 2 children"
    assert_equal 2, Node.find(@root.id).n_descendants, "root cached 2 descendants"
  end

  # todo: this will depend on fixtures and users+groups, OR seeding the test db, but `rake RAILS_ENV=test db:seed` works but they don't seem to show up in tests. IDK
  test "who_can_read" do
    # n = Node.first
    # puts n.to_json, n.who_can_read
    # gs = n.who_can_read
    # assert gs.count > 0
    # assert gs.include?("all")
  end

  test "getting relatives via arel includes self" do
    a_node = Node.first
    [true, false].each do |dir|
      mgr = Node.relatives_via_arel_mgr(dir, a_node.id)
      nodes = Node.find_by_sql(mgr.to_sql)
      assert (nodes.select { |n| n.id == a_node.id }).count == 1
    end
  end

  test "children_rec_arhq sanity" do
    assert_equal 3, Node.all.count, "3 nodes sanity"
    root = Node.find(@root.id)
    puts root.to_json
    puts root.children(nil).to_sql
    assert_equal 2, root.children(nil).count, "2 children sanity"
    cs, descendants_map = root.children_rec_arhq(nil)
    puts cs, descendants_map
    assert_equal 2, descendants_map[root.id].count, "2 children returned"
  end

  test "children_rec_arhq faker" do
    run_faker 10, @admin, @sub_user, @general_user
    _, child_map = @faker_root.children_rec_arhq(nil)
    assert_equal @faker_root.children(nil).count, child_map[@faker_root.id].count, "child counting methods agree"
  end
end
