require "test_helper"
# require "minitest/byebug" if ENV["DEBUG"]

class NodeTest < ActiveSupport::TestCase
  include Cff::NodeFaker

  setup do
    test_setup_3_nodes
  end

  test "user groups" do
    users = 20.times.to_a.map { gen_user gen_random_string, gen_random_email, @test_pw }
    groups = users.map do |u|
      g = create_group u.username
      add_to_group u, g
      g
    end
    users.each do |u|
      assert_equal ["all", u.username].sort, u.groups.sort
    end
  end
end
