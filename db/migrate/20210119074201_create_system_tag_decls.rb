class CreateSystemTagDecls < ActiveRecord::Migration[6.1]
  def change
    create_view :system_tag_decls
  end
end
