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
    resources :reviews, only: %i[index show]
    resources :review_comments, only: %i[index show]
    resources :rulings, only: %i[index show]
    resources :sides, only: %i[index show]
    resources :snapshots, only: %i[index show]
    post :validate_deck, to: 'validate_deck#index'
  end

  scope path: PrivateApplicationResource.endpoint_namespace,
        defaults: { format: :jsonapi },
        constraints: { format: :jsonapi } do
    resources :user, only: %i[index]
    resources :decks
  end
end
