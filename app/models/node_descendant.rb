class NodeDescendant < ApplicationRecord
  attr_reader :base_id, :id, :parent_id, :distance

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: true)
  end
end
