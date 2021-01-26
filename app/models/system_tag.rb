class SystemTag < ApplicationRecord
  attr_reader :id, :td_tag, :anchored_type, :anchored_id, :ut_tag

  def readonly?
    true
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: true, cascade: true)
  end
end
