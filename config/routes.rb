# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/api/docs/', status: 302)

  scope path: ApplicationResource.endpoint_namespace,
        defaults: { format: :jsonapi },
        constraints: { format: :jsonapi } do
    resources :card_cycles, only: %i[index show]
    resources :card_pools, only: %i[index show]
    resources :card_set_types, only: %i[index show]
    resources :card_sets, only: %i[index show]
    resources :card_subtypes, only: %i[index show]
    resources :card_types, only: %i[index show]
    resources :cards, only: %i[index show]
    resources :decklists, only: %i[index show]
    resources :factions, only: %i[index show]
    resources :formats, only: %i[index show]
    resources :illustrators, only: %i[index show]
    resources :printings, only: %i[index show]
    resources :restrictions, only: %i[index show]
    resources :rulings, only: %i[index show]
    resources :sides, only: %i[index show]
    resources :snapshots, only: %i[index show]
  end

  # namespace :api do
  #   namespace :v3 do
  #     namespace :private, defaults: { format: :json } do
  #       # Don't generate links or relationship routes for decks.
  #       jsonapi_resources :decks do
  #       end
  #       jsonapi_resources :user, only: [:index, :show]
  #     end
  #     namespace :public, defaults: { format: :json } do
  #       jsonapi_resources :card_cycles, only: [:index, :show]
  #       jsonapi_resources :card_pools, only: [:index, :show]
  #       jsonapi_resources :card_set_types, only: [:index, :show]
  #       jsonapi_resources :card_sets, only: [:index, :show]
  #       jsonapi_resources :card_subtypes, only: [:index, :show]
  #       jsonapi_resources :card_types, only: [:index, :show]
  #       jsonapi_resources :cards, only: [:index, :show]
  #       jsonapi_resources :decklists, only: [:index, :show]
  #       jsonapi_resources :factions, only: [:index, :show]
  #       jsonapi_resources :formats, only: [:index, :show]
  #       jsonapi_resources :illustrators, only: [:index, :show]
  #       jsonapi_resources :printings, only: [:index, :show]
  #       jsonapi_resources :restrictions, only: [:index, :show]
  #       jsonapi_resources :rulings, only: [:index]
  #       jsonapi_resources :sides, only: [:index, :show]
  #       jsonapi_resources :snapshots, only: [:index, :show]
  #       post :validate_deck, to: 'validate_deck#index'
  #     end
  #   end
  # end
end
