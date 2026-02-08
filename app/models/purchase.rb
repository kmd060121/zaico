class Purchase < ApplicationRecord
  belongs_to :company
  has_many :purchase_items, dependent: :destroy

  validates :num, presence: true
end
