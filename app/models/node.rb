class Node < ApplicationRecord
    belongs_to :author
    belongs_to :parent, class_name: "Node", optional: true
    has_many :content_versions

    has_one :user, through: :author

    # scope :is_top_post, -> (x) { where(is_top_post: x) }
    # scope :genesis, -> (x) { where(genesis_id: x.id) }

    def children
        Node.where(parent_id: self.id).all()
    end

    def content
        c = content_versions.last
        puts c
        puts c.title
        # puts content_versions.last.methods
        puts "^ content versions"
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
end

