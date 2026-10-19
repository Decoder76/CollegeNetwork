class Conversation < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :participants, class_name: "ConversationParticipant", dependent: :destroy
  has_many :active_participants, -> { where(left_at: nil) }, class_name: "ConversationParticipant"
  has_many :active_users, through: :active_participants, source: :user
  has_many :messages, dependent: :destroy
  has_many :invitations, class_name: "ConversationInvitation", dependent: :destroy
  has_many :leave_requests, class_name: "ConversationLeaveRequest", dependent: :destroy

  def active_member?(user)
    active_participants.exists?(user: user)
  end
end
