class UsersGroup < ApplicationRecord
  attr_reader :user_id, :groups
  belongs_to :user, optional: true

  self.primary_key = "user_id"

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: true)
  end
end
