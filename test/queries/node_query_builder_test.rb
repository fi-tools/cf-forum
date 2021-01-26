require "test_helper"
require "queries/node_query_builder"

class NodeQueryBuilderTest < ActiveSupport::TestCase
  setup do
    @nqb = NodeQueryBuilder.new
  end

  test "has correct table and table_name" do
    assert @nqb.table_name == "nodes"
    assert @nqb.table == (Arel::Table.new :nodes)
  end

  test "only 1 node for root ancestors" do
    assert @nqb.relatives_via_arel_mgr(true, base_node_id: 0).run.count == 1
  end

  test "> 1 node for root descendants" do
    assert @nqb.relatives_via_arel_mgr(false, base_node_id: 0).run.count > 1
  end
end
