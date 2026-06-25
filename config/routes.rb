Rails.application.routes.draw do
  root "dashboard#index"

  resources :groups do
    member do
      post :generate_fixtures
    end
  end

  resources :teams

  resources :matches, only: [:index, :edit, :update]

  get  "draw", to: "draw#index",   as: :draw
  post "draw", to: "draw#create"

  get  "knockout",       to: "knockout#index",         as: :knockout
  post "knockout/build", to: "knockout#build",         as: :build_knockout
  get  "qualification",  to: "knockout#qualification", as: :qualification

  get "up" => "rails/health#show", as: :rails_health_check
end
