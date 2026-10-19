class ConversationInvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    set_conversation
    invitee = User.find_by(id: params.expect(:invitee_id))
    if invitee.nil? || invitee == current_user
      redirect_to @conversation, alert: "Choose a different valid user to invite."
      return
    end
    unless current_user.connected_with?(invitee)
      redirect_to @conversation, alert: "You can invite only someone in your network."
      return
    end

    invitation = @conversation.invitations.new(
      invited_by: current_user,
      invitee: invitee,
      status: current_user == @conversation.creator ? "pending_acceptance" : "pending_approval",
      approved_at: current_user == @conversation.creator ? Time.current : nil
    )

    if invitation.save
      redirect_to @conversation, notice: invitation.status == "pending_approval" ?
        "Invitation sent to the conversation owner for approval." :
        "Invitation sent. The user must accept before joining."
    else
      redirect_to @conversation, alert: invitation.errors.full_messages.to_sentence
    end
  end

  def update
    set_conversation
    invitation = @conversation.invitations.find(params.expect(:invitation_id))
    action = params.expect(:decision)

    if invitation.status == "pending_approval" &&
        action == "approve" && current_user.id == @conversation.creator_id
      invitation.update!(status: "pending_acceptance", approved_at: Time.current)
      redirect_to @conversation, notice: "Invitation approved; awaiting the user's acceptance."
    elsif invitation.status == "pending_approval" &&
        action == "decline" && current_user.id == @conversation.creator_id
      invitation.update!(status: "declined")
      redirect_to @conversation, notice: "Invitation declined."
    else
      head :forbidden
    end
  end

  def index
    @invitations = current_user.conversation_invitations_received
      .where(status: "pending_acceptance")
      .includes(:invited_by, :conversation)
  end

  def respond
    invitation = current_user.conversation_invitations_received
      .where(status: "pending_acceptance")
      .find(params.expect(:id))
    decision = params.expect(:decision)

    unless %w[accept decline].include?(decision)
      head :unprocessable_entity
      return
    end

    if decision == "accept"
      Conversation.transaction do
        invitation.update!(status: "accepted", accepted_at: Time.current)
        participant = invitation.conversation.participants.find_or_initialize_by(user: current_user)
        participant.update!(joined_at: Time.current, left_at: nil)
      end
      redirect_to invitation.conversation, notice: "You joined the conversation."
    else
      invitation.update!(status: "declined")
      redirect_to invitations_path, notice: "Invitation declined."
    end
  end

  private

  def set_conversation
    @conversation = Conversation.joins(:active_participants)
      .where(conversation_participants: { user_id: current_user.id, left_at: nil })
      .find(params.expect(:conversation_id))
  end
end
