# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_06_144753) do
  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "deliveries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "num", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "num"], name: "index_deliveries_on_company_id_and_num", unique: true
    t.index ["company_id"], name: "index_deliveries_on_company_id"
  end

  create_table "delivery_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.date "completed_date"
    t.datetime "created_at", null: false
    t.bigint "delivery_id", null: false
    t.bigint "inventory_id", null: false
    t.decimal "quantity", precision: 18, scale: 4, default: "0.0", null: false
    t.date "scheduled_date"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "inventory_id"], name: "index_delivery_items_on_company_id_and_inventory_id"
    t.index ["company_id", "scheduled_date", "status"], name: "idx_on_company_id_scheduled_date_status_5a1b7df709"
    t.index ["company_id"], name: "index_delivery_items_on_company_id"
    t.index ["delivery_id"], name: "index_delivery_items_on_delivery_id"
    t.index ["inventory_id", "scheduled_date", "status"], name: "idx_on_inventory_id_scheduled_date_status_2184c70894"
    t.index ["inventory_id"], name: "index_delivery_items_on_inventory_id"
  end

  create_table "inventories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.decimal "quantity", precision: 18, scale: 4, default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "id"], name: "index_inventories_on_company_id_and_id"
    t.index ["company_id"], name: "index_inventories_on_company_id"
  end

  create_table "purchase_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.date "completed_date"
    t.datetime "created_at", null: false
    t.bigint "inventory_id", null: false
    t.bigint "purchase_id", null: false
    t.decimal "quantity", precision: 18, scale: 4, default: "0.0", null: false
    t.date "scheduled_date"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "inventory_id"], name: "index_purchase_items_on_company_id_and_inventory_id"
    t.index ["company_id", "scheduled_date", "status"], name: "idx_on_company_id_scheduled_date_status_f2de3c71c9"
    t.index ["company_id"], name: "index_purchase_items_on_company_id"
    t.index ["inventory_id", "scheduled_date", "status"], name: "idx_on_inventory_id_scheduled_date_status_82cfca7c40"
    t.index ["inventory_id"], name: "index_purchase_items_on_inventory_id"
    t.index ["purchase_id"], name: "index_purchase_items_on_purchase_id"
  end

  create_table "purchases", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "num", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "num"], name: "index_purchases_on_company_id_and_num", unique: true
    t.index ["company_id"], name: "index_purchases_on_company_id"
  end

  add_foreign_key "deliveries", "companies"
  add_foreign_key "delivery_items", "companies"
  add_foreign_key "delivery_items", "deliveries"
  add_foreign_key "delivery_items", "inventories"
  add_foreign_key "inventories", "companies"
  add_foreign_key "purchase_items", "companies"
  add_foreign_key "purchase_items", "inventories"
  add_foreign_key "purchase_items", "purchases"
  add_foreign_key "purchases", "companies"
end
