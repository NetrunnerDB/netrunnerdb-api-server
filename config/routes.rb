Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api, defaults: { format: :json }, path: '/api/3.0/public/' do
    resources :factions, param: :code, only: [:index, :show]
    resources :sides, param: :code, only: [:index, :show]
    resources :types, param: :code, only: [:index, :show]
    resources :subtypes, param: :code, only: [:index, :show]
  end
end
