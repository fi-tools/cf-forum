class ContentVersion < ApplicationRecord
    # belongs_to :node, optional: true
    belongs_to :author
    belongs_to :node
    
    # belongs_to :parent, class_name: "ContentVersion", optional: true
end