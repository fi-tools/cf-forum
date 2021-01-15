class Entry < ApplicationRecord

    validates :calories, :proteins, :carbs, :fats, :meal_type, presence: true

    def day
        self.created_at.strftime("%b %e, %Y")
    end
end
