json.inventories @inventories do |inventory|
  json.id inventory.id
  json.quantity inventory.quantity
  json.logical_quantity inventory.quantity + (@logical_quantities[inventory.id] || 0)
end

json.pagination do
  json.page @page
  json.limit @limit
end

json.target_date @target_date
