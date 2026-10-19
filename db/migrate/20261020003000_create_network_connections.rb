class CreateNetworkConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :network_connections do |t|
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "pending"
      t.datetime :accepted_at
      t.timestamps
    end

    add_index :network_connections, [ :requester_id, :recipient_id ], unique: true
    add_check_constraint :network_connections, "requester_id <> recipient_id", name: "network_connections_distinct_users"
  end
end
