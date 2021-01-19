class CreateNodeSystemTagCombos < ActiveRecord::Migration[6.1]
  def change
    create_view :node_system_tag_combos
  end
end
