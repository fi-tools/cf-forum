class CreateNodeSystemTagCombos < ActiveRecord::Migration[6.1]
  def change
    create_view :node_system_tag_combos
# Materialization seems problematic without adding refresh logic, and auth stuff stopped working when I added this and was using postgres -MK
#, materialized: true
  end
end
