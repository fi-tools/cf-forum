class UsersGroup < ApplicationRecord
  attr_reader :user_id, :groups

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: true)
  end
end
