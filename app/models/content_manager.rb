class ContentManager < ApplicationRecord
    belongs_to :node
    belongs_to :author
end