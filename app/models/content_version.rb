class ContentVersion < ApplicationRecord
    belongs_to :node
    belongs_to :author
    
    # has_one :parent, ContentVersion
end