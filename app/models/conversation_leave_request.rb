class ConversationLeaveRequest < ApplicationRecord
  STATUSES = %w[pending approved declined].freeze

  belongs_to :conversation
  belongs_to :requester, class_name: "User"
  belongs_to :approver, class_name: "User"

  validates :status, inclusion: { in: STATUSES }
  validates :requester_id, uniqueness: {
    scope: :conversation_id,
    conditions: -> { where(status: "pending") },
    message: "already has a pending request to leave"
  }
end
