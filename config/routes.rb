Rails.application.routes.draw do
  namespace :api do
    namespace :v3 do
      namespace :public, defaults: { format: :json } do
        jsonapi_resources :card_subtypes, param: :code, only: [:index, :show]
        jsonapi_resources :card_types, param: :code, only: [:index, :show]
        jsonapi_resources :factions, param: :code, only: [:index, :show]
        jsonapi_resources :sides, param: :code, only: [:index, :show]
      end
    end
  end
end
