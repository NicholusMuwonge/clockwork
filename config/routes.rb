# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount Sidekiq::Web => '/sidekiq'

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      root 'home#index'
      get 'issues/components/without_lead', to: 'components#sync_unassigned_components_with_issue_count'
    end
  end
end
