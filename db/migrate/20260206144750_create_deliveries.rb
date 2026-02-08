class CreateDeliveries < ActiveRecord::Migration[8.1]
  def change
    create_table :deliveries do |t|
      t.references :company, null: false, foreign_key: true, type: :bigint
      t.string :num, null: false
      t.timestamps
    end

    add_index :deliveries, [:company_id, :num], unique: true
  end
end
