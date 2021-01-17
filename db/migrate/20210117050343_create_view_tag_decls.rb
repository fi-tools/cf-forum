class CreateViewTagDecls < ActiveRecord::Migration[6.1]
  def change
    create_view :view_tag_decls
  end
end
