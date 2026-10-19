# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_20_003000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "conversation_invitations", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "invited_by_id", null: false
    t.bigint "invitee_id", null: false
    t.string "status", default: "pending_approval", null: false
    t.datetime "approved_at"
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversation_invitations_on_conversation_id"
    t.index ["invited_by_id"], name: "index_conversation_invitations_on_invited_by_id"
    t.index ["invitee_id"], name: "index_conversation_invitations_on_invitee_id"
  end

  create_table "conversation_leave_requests", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "requester_id", null: false
    t.bigint "approver_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "decided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approver_id"], name: "index_conversation_leave_requests_on_approver_id"
    t.index ["conversation_id"], name: "index_conversation_leave_requests_on_conversation_id"
    t.index ["requester_id"], name: "index_conversation_leave_requests_on_requester_id"
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.datetime "joined_at", null: false
    t.datetime "left_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "user_id"], name: "index_conversation_participants_on_conversation_id_and_user_id", unique: true
    t.index ["conversation_id"], name: "index_conversation_participants_on_conversation_id"
    t.index ["user_id"], name: "index_conversation_participants_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_conversations_on_creator_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "conversation_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "network_connections", force: :cascade do |t|
    t.bigint "requester_id", null: false
    t.bigint "recipient_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipient_id"], name: "index_network_connections_on_recipient_id"
    t.index ["requester_id", "recipient_id"], name: "index_network_connections_on_requester_id_and_recipient_id", unique: true
    t.index ["requester_id"], name: "index_network_connections_on_requester_id"
    t.check_constraint "requester_id <> recipient_id", name: "network_connections_distinct_users"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "bio"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.integer "role", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "conversation_invitations", "conversations"
  add_foreign_key "conversation_invitations", "users", column: "invited_by_id"
  add_foreign_key "conversation_invitations", "users", column: "invitee_id"
  add_foreign_key "conversation_leave_requests", "conversations"
  add_foreign_key "conversation_leave_requests", "users", column: "approver_id"
  add_foreign_key "conversation_leave_requests", "users", column: "requester_id"
  add_foreign_key "conversation_participants", "conversations"
  add_foreign_key "conversation_participants", "users"
  add_foreign_key "conversations", "users", column: "creator_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "network_connections", "users", column: "recipient_id"
  add_foreign_key "network_connections", "users", column: "requester_id"
  add_foreign_key "posts", "users"
  add_foreign_key "profiles", "users"
end
