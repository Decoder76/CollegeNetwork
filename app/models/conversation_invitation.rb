class ConversationInvitation < ApplicationRecord
  STATUSES = %w[pending_approval pending_acceptance accepted declined].freeze

  belongs_to :conversation
  belongs_to :invited_by, class_name: "User"
  belongs_to :invitee, class_name: "User"

  validates :status, inclusion: { in: STATUSES }
  validate :invitee_is_not_active_participant
  validate :no_duplicate_pending_invitation
  validate :inviter_is_connected_to_invitee, on: :create

  private

  def invitee_is_not_active_participant
    return unless conversation && invitee
    return unless conversation.active_member?(invitee)

    errors.add(:invitee, "is already in this conversation")
  end

  def no_duplicate_pending_invitation
    return unless conversation && invitee

    pending = conversation.invitations
      .where(invitee_id: invitee_id, status: %w[pending_approval pending_acceptance])
    pending = pending.where.not(id: id) if persisted?
    errors.add(:invitee, "already has a pending invitation") if pending.exists?
  end

  def inviter_is_connected_to_invitee
    return unless invited_by && invitee
    return if invited_by.connected_with?(invitee)

    errors.add(:invitee, "must be in the inviter's network")
  end
end
