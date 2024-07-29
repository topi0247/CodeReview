# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  root 'static_pages#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: :logout
  post '/try', to: 'static_pages#try', as: :try

  resources :repositories, only: %i[index show] do
    post 'file', on: :member
    post 'code_review', on: :member
    resources :review_logs, only: %i[create destroy]
  end
end
