class NodeInheritedAuthzRead < ApplicationRecord
  attr_reader :id, :groups

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: true)
  end
end
