class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
    enum :role, { student: 0, faculty: 1, admin: 2 } # Role-based access
    validates :name, presence: true
    has_many :comments
    has_many :likes
end
