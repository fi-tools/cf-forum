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
end
