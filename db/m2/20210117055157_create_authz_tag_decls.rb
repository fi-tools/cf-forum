class CreateAuthzTagDecls < ActiveRecord::Migration[6.1]
  def change
    create_view :authz_tag_decls
  end
end
