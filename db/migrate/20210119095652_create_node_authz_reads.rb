class CreateNodeAuthzReads < ActiveRecord::Migration[6.1]
  def change
    create_view :node_authz_reads, materialized: true
  end
end
