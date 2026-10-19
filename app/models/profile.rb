class Profile < ApplicationRecord
  belongs_to :user

  enum :role, { student: 0, faculty: 1, admin: 2 }, validate: true

  validates :name, :role, presence: true
end
