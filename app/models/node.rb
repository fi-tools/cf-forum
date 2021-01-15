class Node < ApplicationRecord
    belongs_to :author
    belongs_to :content_version
    belongs_to :parent, class_name: "Node"
    # belongs_to :genesis, class_name: "Node"

    has_one :user, through: :author

    # scope :is_top_post, -> (x) { where(is_top_post: x) }
    # scope :genesis, -> (x) { where(genesis_id: x.id) }

    def replies
        # Node.genesis(self).all()
        # Node.where(parent_id: self.id).all
    end

    def children
        Node.where(parent_id: self.id).all()
    end
end

