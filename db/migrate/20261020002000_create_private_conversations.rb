require "set"

class CreatePrivateConversations < ActiveRecord::Migration[8.0]
  class LegacyUser < ActiveRecord::Base
    self.table_name = "users"
  end

  class LegacyMessage < ActiveRecord::Base
    self.table_name = "messages"
  end

  class LegacyConversation < ActiveRecord::Base
    self.table_name = "conversations"
  end

  class LegacyParticipant < ActiveRecord::Base
    self.table_name = "conversation_participants"
  end

  def up
    create_table :conversations do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    create_table :conversation_participants do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :joined_at, null: false
      t.datetime :left_at
      t.timestamps
    end
    add_index :conversation_participants, [ :conversation_id, :user_id ], unique: true

    create_table :conversation_invitations do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.references :invitee, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending_approval"
      t.datetime :approved_at
      t.datetime :accepted_at
      t.timestamps
    end

    create_table :conversation_leave_requests do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :approver, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"
      t.datetime :decided_at
      t.timestamps
    end

    add_reference :messages, :conversation, foreign_key: true

    backfill_legacy_messages
  end

  def down
    remove_reference :messages, :conversation, foreign_key: true
    drop_table :conversation_leave_requests
    drop_table :conversation_invitations
    drop_table :conversation_participants
    drop_table :conversations
  end

  private

  def backfill_legacy_messages
    pairs = LegacyMessage.where.not(sender_id: nil, receiver_id: nil)
      .pluck(:sender_id, :receiver_id)
      .map(&:sort)
      .uniq
    valid_user_ids = LegacyUser.where(id: pairs.flatten.uniq).pluck(:id).to_set
    timestamp = Time.current

    pairs.each do |first_user_id, second_user_id|
      next unless valid_user_ids.include?(first_user_id) && valid_user_ids.include?(second_user_id)

      conversation = LegacyConversation.create!(creator_id: first_user_id)
      participant_ids = [ first_user_id, second_user_id ].uniq
      LegacyParticipant.insert_all!(participant_ids.map do |user_id|
        {
          conversation_id: conversation.id,
          user_id: user_id,
          joined_at: timestamp,
          created_at: timestamp,
          updated_at: timestamp
        }
      end)

      LegacyMessage.where(sender_id: first_user_id, receiver_id: second_user_id)
        .or(LegacyMessage.where(sender_id: second_user_id, receiver_id: first_user_id))
        .update_all(conversation_id: conversation.id)
    end
  end
end
