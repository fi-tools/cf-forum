class Author < ApplicationRecord
    # validates :name, :public?

    belongs_to :user
end