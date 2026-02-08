class CreatePurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :purchases do |t|
      t.references :company, null: false, foreign_key: true, type: :bigint
      t.string :num, null: false
      t.timestamps
    end

    add_index :purchases, [:company_id, :num], unique: true
  end
end
