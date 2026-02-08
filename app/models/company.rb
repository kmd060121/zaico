class Company < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :deliveries, dependent: :destroy
  has_many :delivery_items, dependent: :destroy
  has_many :purchases, dependent: :destroy
  has_many :purchase_items, dependent: :destroy

  validates :name, presence: true
end
