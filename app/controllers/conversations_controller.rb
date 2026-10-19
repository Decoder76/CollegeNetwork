class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: :show

  def index
    @conversations = Conversation.joins(:active_participants)
      .where(conversation_participants: { user_id: current_user.id, left_at: nil })
      .includes(:active_users, messages: :sender)
      .order(updated_at: :desc)
  end

  def show
    @messages = @conversation.messages.includes(:sender).order(:created_at)
    @users = current_user.connected_users
      .where.not(id: @conversation.active_participants.select(:user_id))
      .order(:name)
    @pending_invitee_ids = @conversation.invitations
      .where(status: %w[pending_approval pending_acceptance])
      .select(:invitee_id)
    @invitations_to_approve = if current_user == @conversation.creator
      @conversation.invitations.where(status: "pending_approval").includes(:invited_by, :invitee)
    else
      ConversationInvitation.none
    end
    @pending_leave_requests = @conversation.leave_requests
      .where(approver: current_user, status: "pending")
      .includes(:requester)
    @my_leave_request = @conversation.leave_requests.find_by(requester: current_user, status: "pending")
  end

  def new
    @users = User.where.not(id: current_user.id).order(:name)
  end

  def create
    recipient_id = params.expect(conversation: [ :recipient_id ])[:recipient_id]
    recipient = User.find_by(id: recipient_id)

    unless recipient && recipient != current_user
      @users = User.where.not(id: current_user.id).order(:name)
      @error = "Choose another valid user to start a conversation."
      render :new, status: :unprocessable_entity
      return
    end

    Conversation.transaction do
      @conversation = Conversation.create!(creator: current_user)
      @conversation.participants.create!([
        { user: current_user, joined_at: Time.current },
        { user: recipient, joined_at: Time.current }
      ])
    end

    redirect_to @conversation, notice: "Conversation started."
  end

  private

  def set_conversation
    @conversation = Conversation.joins(:active_participants)
      .where(conversation_participants: { user_id: current_user.id, left_at: nil })
      .find(params.expect(:id))
  end
end
