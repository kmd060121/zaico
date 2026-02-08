class CreateInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :inventories do |t|
      t.references :company, null: false, foreign_key: true
      t.decimal :quantity, null: false, precision: 18, scale: 4, default: 0
      t.timestamps
    end

    add_index :inventories, [:company_id, :id]
  end
end
