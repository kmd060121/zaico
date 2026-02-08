class CreateDeliveryItems < ActiveRecord::Migration[8.1]
  def change
    create_table :delivery_items do |t|
      t.references :company, null: false, foreign_key: true, type: :bigint
      t.references :delivery, null: false, foreign_key: true, type: :bigint
      t.references :inventory, null: false, foreign_key: true, type: :bigint
      t.string :status, null: false
      t.date :scheduled_date
      t.date :completed_date
      t.decimal :quantity, null: false, precision: 18, scale: 4, default: 0
      t.timestamps
    end

    add_index :delivery_items, [:company_id, :inventory_id]
    add_index :delivery_items, [:company_id, :scheduled_date, :status]
    add_index :delivery_items, [:inventory_id, :scheduled_date, :status]
  end
end
