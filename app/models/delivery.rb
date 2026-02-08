class Delivery < ApplicationRecord
  belongs_to :company
  has_many :delivery_items, dependent: :destroy

  validates :num, presence: true
end
