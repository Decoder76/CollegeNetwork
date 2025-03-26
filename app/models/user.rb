class User < ApplicationRecord
    enum role: { student: 0, faculty: 1, admin: 2 } # Role-based access
      validates :name, presence: true
end
