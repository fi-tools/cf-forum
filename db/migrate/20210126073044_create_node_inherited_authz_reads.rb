class CreateNodeInheritedAuthzReads < ActiveRecord::Migration[6.1]
  def change
    create_view :node_inherited_authz_reads, materialized: true
    add_index :node_inherited_authz_reads, :node_id, unique: true
  end
end
