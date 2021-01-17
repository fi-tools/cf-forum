class Node < ApplicationRecord
  belongs_to :author
  belongs_to :parent, class_name: "Node", optional: true
  has_many :content_versions

  has_one :user, through: :author
  has_many :direct_children, class_name: "Node", foreign_key: :parent_id

  # scope :is_top_post, -> (x) { where(is_top_post: x) }
  # scope :genesis, -> (x) { where(genesis_id: x.id) }

  # def children
  #   Node.where(parent_id: self.id).all()
  # end

  def content
    c = content_versions.last
    # puts c
    # puts c.title
    # # puts content_versions.last.methods
    # puts "^ content versions"
    c
  end

  def content_version
    warn "Deprecation: Node.content_version"
    content
  end

  def depth
    if self.parent == nil
      0
    else
      self.parent.depth + 1
    end
  end

  def children_rec(rec = false)
    if !rec
      return direct_children
    end
    Node.where("id in (#{self.children_rec_sql(self)}) AND id != ?", [self.id])
  end

  private

  def children_rec_sql(node)
    table_name = Node.table_name
    <<-SQL
        WITH RECURSIVE search_tree(p_id) AS (
            SELECT id
            FROM #{table_name}
            WHERE id = #{node.id}
          UNION ALL
            SELECT id
            FROM search_tree, #{table_name} o
            WHERE search_tree.p_id = o.parent_id
        )
        SELECT * FROM search_tree
    SQL
  end
end
