require "test_helper"

class NodesControllerTest < ActiveSupport::TestCase
  test "unknown node returns 404" do
    skip "todo"

    assert_raises(ActionController::RoutingError) do
      get "/something/you/want/to/404"
    end
  end

  test "node that user isn't authzed for returns 404" do
    skip "todo"

    assert_raises(ActionController::RoutingError) do
      get "/something/you/want/to/404"
    end
  end
end
