require "test_helper"
# require "minitest/byebug" if ENV["DEBUG"]

class NodeTest < ActiveSupport::TestCase
  setup do
    pw = "hunter2"
    admin_email = "#{SecureRandom.hex(12)}@xk.io"
    admin = User.create! :username => SecureRandom.hex(12), :email => admin_email, :password => pw
    @admin_author = Author.find_or_create_by! :user => admin, :name => SecureRandom.hex(12), :public => true

    @nodes = []
    @root = create_node(0, "root", nil, author: @admin_author)
    @nodes << @root
    @nodes << create_node(nil, "reply1", @root.id, author: @admin_author)
    @nodes << create_node(nil, "reply2", @root.id, author: @admin_author)
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
end
