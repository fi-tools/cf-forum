class NodeSystemTag < ApplicationRecord
  attr_reader :node_id, :td_tag, :ut_tag
  belongs_to :node

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: true)
  end
end
