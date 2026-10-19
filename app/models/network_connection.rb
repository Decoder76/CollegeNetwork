class NetworkConnection < ApplicationRecord
  STATUSES = %w[pending accepted declined].freeze

  belongs_to :requester, class_name: "User"
  belongs_to :recipient, class_name: "User"

  scope :accepted, -> { where(status: "accepted") }

  validates :status, inclusion: { in: STATUSES }
  validate :users_are_distinct
  validate :connection_does_not_already_exist

  private

  def users_are_distinct
    errors.add(:recipient, "must be a different user") if requester_id.present? && requester_id == recipient_id
  end

  def connection_does_not_already_exist
    return unless requester_id && recipient_id

    existing = self.class.where(
      "(requester_id = :requester AND recipient_id = :recipient) OR (requester_id = :recipient AND recipient_id = :requester)",
      requester: requester_id,
      recipient: recipient_id
    )
    existing = existing.where.not(id: id) if persisted?
    errors.add(:base, "A connection request or connection already exists") if existing.where.not(status: "declined").exists?
  end
end
