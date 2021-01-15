class Node < ApplicationRecord
    belongs_to :author
    belongs_to :content_version
    belongs_to :parent, class_name: "Node"
    belongs_to :genesis, class_name: "Node"

    has_one :user, through: :author
    
    attr_accessor :is_top_post, :genesis_id
end

