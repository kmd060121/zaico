class Inventory < ApplicationRecord
  belongs_to :company
  has_many :delivery_items, dependent: :destroy
  has_many :purchase_items, dependent: :destroy

  validates :quantity, numericality: true

  def logical_quantity_at(date)
    InventoryLogicalQuantityService.new(company: company).logical_quantity_for_inventory(id, date)
  end
end
