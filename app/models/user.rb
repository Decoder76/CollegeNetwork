class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum :role, { student: 0, faculty: 1, admin: 2 }

  validates :name, presence: true

  has_many :posts, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :conversation_participations, class_name: "ConversationParticipant", dependent: :destroy
  has_many :conversations, through: :conversation_participations
  has_many :conversation_invitations_received, class_name: "ConversationInvitation", foreign_key: :invitee_id, dependent: :destroy
  has_many :conversation_invitations_sent, class_name: "ConversationInvitation", foreign_key: :invited_by_id, dependent: :destroy
  has_many :conversation_leave_requests_received, class_name: "ConversationLeaveRequest", foreign_key: :approver_id, dependent: :destroy
  has_many :conversation_leave_requests_sent, class_name: "ConversationLeaveRequest", foreign_key: :requester_id, dependent: :destroy
  has_many :connections_requested, class_name: "NetworkConnection", foreign_key: :requester_id, dependent: :destroy
  has_many :connections_received, class_name: "NetworkConnection", foreign_key: :recipient_id, dependent: :destroy

  def connected_users
    requested_ids = NetworkConnection.accepted.where(requester_id: id).select(:recipient_id)
    received_ids = NetworkConnection.accepted.where(recipient_id: id).select(:requester_id)
    User.where(id: requested_ids).or(User.where(id: received_ids))
  end

  def connected_with?(other_user)
    connected_users.exists?(id: other_user.id)
  end
end
