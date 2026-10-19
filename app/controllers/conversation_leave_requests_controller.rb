class ConversationLeaveRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    if @conversation.active_participants.count < 2
      redirect_to @conversation, alert: "You cannot leave a conversation with no other participants."
      return
    end

    invitation = @conversation.invitations
      .where(invitee: current_user, status: "accepted")
      .order(accepted_at: :desc)
      .first
    approver_id = invitation&.invited_by_id
    unless @conversation.active_participants.exists?(user_id: approver_id)
      approver_id = @conversation.creator_id
    end
    if approver_id == current_user.id
      approver_id = @conversation.active_participants.where.not(user_id: current_user.id).pick(:user_id)
    end

    request = @conversation.leave_requests.new(requester: current_user, approver_id: approver_id)
    if request.save
      redirect_to @conversation, notice: "Your request to leave was sent for approval."
    else
      redirect_to @conversation, alert: request.errors.full_messages.to_sentence
    end
  end

  def update
    request = @conversation.leave_requests.find(params.expect(:leave_request_id))
    decision = params.expect(:decision)
    unless request.approver_id == current_user.id && request.status == "pending" &&
        %w[approve decline].include?(decision)
      head :forbidden
      return
    end

    Conversation.transaction do
      if decision == "approve"
        @conversation.participants.find_by!(user: request.requester, left_at: nil).update!(left_at: Time.current)
        request.update!(status: "approved", decided_at: Time.current)
      else
        request.update!(status: "declined", decided_at: Time.current)
      end
    end

    redirect_to @conversation, notice: decision == "approve" ?
      "#{request.requester.name} has left the conversation." : "Leave request declined."
  end

  private

  def set_conversation
    @conversation = Conversation.joins(:active_participants)
      .where(conversation_participants: { user_id: current_user.id, left_at: nil })
      .find(params.expect(:conversation_id))
  end
end
