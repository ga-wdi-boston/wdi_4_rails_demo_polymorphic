Rails.application.routes.draw do
  devise_for :users
  resources :statuses, only: [:show, :new, :create]
  resources :links, only: [:show, :new, :create]
  root 'home#show'
end
