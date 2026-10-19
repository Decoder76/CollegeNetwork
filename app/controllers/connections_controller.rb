class ConnectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    @connections = NetworkConnection.accepted
      .where("requester_id = :id OR recipient_id = :id", id: current_user.id)
      .includes(:requester, :recipient)
    @incoming_requests = current_user.connections_received.where(status: "pending").includes(:requester)
    @outgoing_requests = current_user.connections_requested.where(status: "pending").includes(:recipient)
    unavailable_ids = NetworkConnection.where(
      "requester_id = :id OR recipient_id = :id",
      id: current_user.id
    ).where.not(status: "declined").pluck(:requester_id, :recipient_id).flatten
    @users = User.where.not(id: unavailable_ids + [ current_user.id ]).order(:name)
  end

  def create
    recipient = User.find_by(id: params.expect(:recipient_id))
    if recipient.nil? || recipient == current_user
      redirect_to connections_path, alert: "Choose another valid user."
      return
    end

    connection = NetworkConnection.where(
      "(requester_id = :id AND recipient_id = :other) OR (requester_id = :other AND recipient_id = :id)",
      id: current_user.id,
      other: recipient.id
    ).first

    if connection && connection.status != "declined"
      redirect_to connections_path, alert: "A request or connection already exists."
      return
    end

    connection ||= NetworkConnection.new
    connection.assign_attributes(requester: current_user, recipient: recipient, status: "pending", accepted_at: nil)

    if connection.save
      redirect_to connections_path, notice: "Connection request sent."
    else
      redirect_to connections_path, alert: connection.errors.full_messages.to_sentence
    end
  end

  def update
    connection = current_user.connections_received.where(status: "pending").find(params.expect(:id))
    decision = params.expect(:decision)

    unless %w[accept decline].include?(decision)
      head :unprocessable_entity
      return
    end

    connection.update!(status: decision == "accept" ? "accepted" : "declined",
      accepted_at: decision == "accept" ? Time.current : nil)
    redirect_to connections_path, notice: decision == "accept" ? "Connection accepted." : "Request declined."
  end

  def destroy
    connection = NetworkConnection.accepted
      .where("requester_id = :id OR recipient_id = :id", id: current_user.id)
      .find(params.expect(:id))
    connection.destroy!
    redirect_to connections_path, notice: "Connection removed. Conversation membership was not changed."
  end
end
