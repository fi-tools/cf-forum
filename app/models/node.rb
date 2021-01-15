class Node < ApplicationRecord
    belongs_to :author
    belongs_to :content_version
    belongs_to :parent, class_name: "Node"
    belongs_to :genesis, class_name: "Node"
end
