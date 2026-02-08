class Api::InventoryLogicalQuantitiesController < Api::BaseController
  before_action :ensure_company!

  def show
    return unless current_company

    from = params[:from].presence || Date.current
    to = params[:to].presence || (Date.current + 30)

    service = InventoryLogicalQuantityService.new(company: current_company)
    @inventory, @points = service.trend_for_inventory(
      inventory_id: params[:inventory_id],
      from: from,
      to: to
    )
  end
end
