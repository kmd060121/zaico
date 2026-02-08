class Api::InventoriesController < Api::BaseController
  before_action :ensure_company!

  LIMIT = 50

  def index
    return unless current_company

    page = params.fetch(:page, 1).to_i
    service = InventoryLogicalQuantityService.new(company: current_company)
    inventories, target_date, logical_deltas = service.list_with_logical_quantities(
      date: params[:date] || Date.current,
      page: page,
      limit: LIMIT
    )

    @inventories = inventories
    @target_date = target_date
    @logical_quantities = logical_deltas
    @page = [page, 1].max
    @limit = LIMIT
  end
end
