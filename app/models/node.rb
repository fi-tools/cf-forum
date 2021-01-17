class Node < ApplicationRecord
  belongs_to :author
  belongs_to :parent, class_name: "Node", optional: true
  has_many :content_versions

  has_one :user, through: :author
  has_many :direct_children, class_name: "Node", foreign_key: :parent_id

  has_many :anchoring_tags, as: :anchored, class_name: "TagDecl"
  has_many :targeting_tags, as: :target, class_name: "TagDecl"
  has_many :anchored_usertags, through: :anchoring_tags, source: :target, source_type: "UserTag"

  # has_many
  has_many :anchoring_view_tags, as: :anchored, class_name: "ViewTagDecl"
  has_many :anchored_view_tags, through: :anchoring_view_tags, source: :target, source_type: "UserTag"

  after_create :set_tags

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

  def view
    self.anchored_view_tags.last.tag
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

  def set_tags
    p = self.parent
    if !p.nil?
      # p_view = p.anchoring_tags.where(:tag => :view, :target_type => :UserTag, :user_id => nil).last
      # puts "expecting to find tags: #{p_view.to_json}"
      view_tag = p.anchored_view_tags.all.last
      if view_tag.nil?
        throw "No tags :*( #{p.to_yaml}"
      end
      new_vt = case view_tag.tag
        when "root"
          :index
        when "index"
          :topic
        when "topic"
          :comment
        when "comment"
          :comment
        else
          throw "Unrecognised view_tag: #{view_tag.to_json}"
        end

      TagDecl.create! :tag => :view, :user => nil, :anchored => self, :target => UserTag.find_global(new_vt).first
    end
  end
end
