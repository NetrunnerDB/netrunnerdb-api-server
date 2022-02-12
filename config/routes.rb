Rails.application.routes.draw do
  namespace :api, defaults: { format: :json }, path: '/api/3.0/public/' do
    jsonapi_resources :card_subtypes, param: :code, only: [:index, :show]
    jsonapi_resources :card_types, param: :code, only: [:index, :show]
    jsonapi_resources :factions, param: :code, only: [:index, :show]
    jsonapi_resources :sides, param: :code, only: [:index, :show]
  end
end
