Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :inventories, only: [:show]

  namespace :api do
    resources :inventories, only: [:index], defaults: { format: :json } do
      resource :logical_quantities,
               only: [:show],
               controller: "inventory_logical_quantities",
               defaults: { format: :json }
    end
  end
end
