require "test_helper"
# require "minitest/byebug" if ENV["DEBUG"]

class NodeTest < ActiveSupport::TestCase
  include Cff::NodeFaker

  setup do
    test_setup_3_nodes
  end

  # called after every single test
  teardown do
    # when controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear
  end

  test "node record should have accurate n_descendants, n_children, and depth" do
    assert_equal 0, Node.find(@root.id).depth, "root has depth 0"
    assert_equal 2, Node.find(@root.id).n_children, "root cached 2 children"
    assert_equal 2, Node.find(@root.id).n_descendants, "root cached 2 descendants"
  end

  test "children_rec_arhq sanity" do
    # note: we sometimes have more than 3 nodes in the db, but also multiple roots... not sure why this happens. db not being reset on teardown?
    assert_equal 3, Node.descendants_raw(@root.id).count, "3 nodes sanity"
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

  test "children_rec_arhq returns sorted lists" do
    run_faker 11, @admin, @sub_user, @general_user
    _, child_map = @faker_root.children_rec_arhq(nil)
    child_map.each_value do |v|
      assert_equal v.sort, v, "children are sorted"
    end
  end

  test "children_rec_arhq resepects Authz.read permissions on nodes" do
    skip "todo"
  end

  test "when a custom view tag is set on a node (by node's author or system) it's returned from .view" do
    skip "impl me - needed for blog stuff?"
  end
end
