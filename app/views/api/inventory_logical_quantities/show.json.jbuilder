json.inventory_id @inventory.id
json.points @points do |point|
  json.date point[:date]
  json.logical_quantity point[:logical_quantity]
end
