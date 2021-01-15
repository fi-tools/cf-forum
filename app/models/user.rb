class User < ApplicationRecord
    # validates :username, :hex_pw_hash, :email

    has_many :authors
end