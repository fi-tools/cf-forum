class ContentVersion < ApplicationRecord
    belongs_to :node
    belongs_to :author
    
    belongs_to :parent, class_name: "ContentVersion"
end