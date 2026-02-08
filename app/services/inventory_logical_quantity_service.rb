class InventoryLogicalQuantityService
  DEFAULT_LIMIT = 50

  def initialize(company:)
    @company = company
  end

  def list_with_logical_quantities(date:, page: 1, limit: DEFAULT_LIMIT)
    target_date = clamp_date(date)
    page = [page.to_i, 1].max
    limit = [limit.to_i, 1].max

    relation = company.inventories.order(:id)
    inventories = relation.offset((page - 1) * limit).limit(limit).to_a

    logical_by_inventory_id = logical_delta_grouped_by_inventory(
      inventory_ids: inventories.map(&:id),
      target_date: target_date
    )

    [inventories, target_date, logical_by_inventory_id]
  end

  def logical_quantity_for_inventory(inventory_id, date)
    target_date = clamp_date(date)
    inventory = company.inventories.find(inventory_id)

    delta = logical_delta_grouped_by_inventory(
      inventory_ids: [inventory.id],
      target_date: target_date
    )[inventory.id] || 0

    inventory.quantity + delta
  end

  def trend_for_inventory(inventory_id:, from:, to:)
    from_date = clamp_date(from)
    to_date = [to.to_date, from_date].max
    inventory = company.inventories.find(inventory_id)

    purchase_sums = company.purchase_items.not_completed
      .where(inventory_id: inventory.id)
      .where(scheduled_date: from_date..to_date)
      .group(:scheduled_date)
      .sum(:quantity)

    delivery_sums = company.delivery_items.not_completed
      .where(inventory_id: inventory.id)
      .where(scheduled_date: from_date..to_date)
      .group(:scheduled_date)
      .sum(:quantity)

    running = inventory.quantity
    points = []
    (from_date..to_date).each do |date|
      running += (purchase_sums[date] || 0)
      running -= (delivery_sums[date] || 0)
      points << { date: date, logical_quantity: running }
    end

    [inventory, points]
  end

  private

  attr_reader :company

  def clamp_date(date)
    parsed = date.to_date
    parsed < Date.current ? Date.current : parsed
  rescue ArgumentError, NoMethodError
    Date.current
  end

  def logical_delta_grouped_by_inventory(inventory_ids:, target_date:)
    return {} if inventory_ids.empty?

    purchase_sums = company.purchase_items.not_completed
      .where(inventory_id: inventory_ids)
      .where("scheduled_date <= ?", target_date)
      .group(:inventory_id)
      .sum(:quantity)

    delivery_sums = company.delivery_items.not_completed
      .where(inventory_id: inventory_ids)
      .where("scheduled_date <= ?", target_date)
      .group(:inventory_id)
      .sum(:quantity)

    inventory_ids.each_with_object({}) do |inventory_id, result|
      result[inventory_id] = (purchase_sums[inventory_id] || 0) - (delivery_sums[inventory_id] || 0)
    end
  end
end
