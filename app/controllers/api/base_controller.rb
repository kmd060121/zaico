class Api::BaseController < ActionController::API
  private

  def current_company
    @current_company ||= begin
      id = params[:company_id]
      id.present? ? Company.find(id) : Company.order(:id).first
    end
  end

  def ensure_company!
    return if current_company

    render json: { error: "company is not found" }, status: :not_found
  end
end
