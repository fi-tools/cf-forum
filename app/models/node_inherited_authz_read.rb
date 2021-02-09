class NodeInheritedAuthzRead < ApplicationRecord
  attr_reader :node_id, :parent_id, :groups
  belongs_to :node

  self.primary_key = :node_id

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
