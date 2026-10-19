class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User", optional: true

  validates :content, presence: true
  validate :sender_is_active_participant, if: :conversation

  private

  def sender_is_active_participant
    return if conversation.active_member?(sender)

    errors.add(:sender, "must be an active conversation participant")
  end
end
