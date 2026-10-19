class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation
  before_action :set_message, only: %i[update destroy]
  before_action :authorize_message, only: %i[update destroy]

  def create
    @message = @conversation.messages.build(message_params.merge(sender: current_user))

    if @message.save
      redirect_to @conversation, notice: "Message sent."
    else
      redirect_to @conversation, alert: @message.errors.full_messages.to_sentence
    end
  end

  def update
    if @message.update(message_params)
      redirect_to @conversation, notice: "Message updated."
    else
      redirect_to @conversation, alert: @message.errors.full_messages.to_sentence
    end
  end

  def destroy
    @message.destroy!
    redirect_to @conversation, notice: "Message deleted."
  end

  private

  def set_conversation
    @conversation = Conversation.joins(:active_participants)
      .where(conversation_participants: { user_id: current_user.id, left_at: nil })
      .find(params.expect(:conversation_id))
  end

  def set_message
    @message = @conversation.messages.find(params.expect(:id))
  end

  def authorize_message
    head :not_found unless @message.sender_id == current_user.id
  end

  def message_params
    params.expect(message: [ :content ])
  end
end
