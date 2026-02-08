class DeliveryItem < ApplicationRecord
  STATUSES = %w[none before completed].freeze

  belongs_to :company
  belongs_to :delivery
  belongs_to :inventory

  validates :status, inclusion: { in: STATUSES }
  validates :quantity, numericality: true

  scope :not_completed, -> { where.not(status: "completed") }
end
