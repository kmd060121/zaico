class CreatePurchaseItems < ActiveRecord::Migration[8.1]
  def change
    create_table :purchase_items do |t|
      t.references :company, null: false, foreign_key: true, type: :bigint
      t.references :purchase, null: false, foreign_key: true, type: :bigint
      t.references :inventory, null: false, foreign_key: true, type: :bigint
      t.string :status, null: false
      t.date :scheduled_date
      t.date :completed_date
      t.decimal :quantity, null: false, precision: 18, scale: 4, default: 0
      t.timestamps
    end

    add_index :purchase_items, [:company_id, :inventory_id]
    add_index :purchase_items, [:company_id, :scheduled_date, :status]
    add_index :purchase_items, [:inventory_id, :scheduled_date, :status]
  end
end
