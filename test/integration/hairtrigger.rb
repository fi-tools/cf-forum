require "test_helper"

class HairtriggerTest < ActiveSupport::TestCase
  test "triggers current" do
    assert HairTrigger::migrations_current?
  end
end
