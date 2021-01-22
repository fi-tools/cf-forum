require "test_helper"

class NodeTest < ActiveSupport::TestCase
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
