# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  root 'static_pages#index'

  get '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/github', as: :github_login
  delete '/logout', to: 'sessions#destroy', as: :logout
end
