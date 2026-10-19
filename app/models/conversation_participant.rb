class ConversationParticipant < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  scope :active, -> { where(left_at: nil) }

  validates :user_id, uniqueness: { scope: :conversation_id }
end
