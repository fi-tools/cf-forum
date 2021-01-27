require "test_helper"
# require "minitest/byebug" if ENV["DEBUG"]

class NodeTest < ActiveSupport::TestCase
  include Cff::NodeFaker

  setup do
    puts "running setuop"
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

  test "children_rec_arhq sanity" do
    puts Node.all.inspect
    assert_equal 3, Node.all.count, "3 nodes sanity"
    root = Node.find(@root.id)
    Rails::logger.info root.to_json
    Rails::logger.info root.children_direct(nil).to_sql
    assert_equal 2, root.children_direct(nil).count, "2 children sanity"
    cs, descendants_map = root.children_rec_arhq(nil)
    puts cs, descendants_map
    assert_equal 2, descendants_map[root.id].count, "2 children returned"
  end

  test "children_rec_arhq faker" do
    run_faker 11, @admin, @sub_user, @general_user
    _, child_map = @faker_root.children_rec_arhq(nil)
    assert_equal @faker_root.children_direct(nil).count, child_map[@faker_root.id].count, "child counting methods agree"
  end
end
