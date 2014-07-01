Rails.application.routes.draw do
  devise_for :users

  resources :statuses, only: [:show, :new, :create] do
    resources :comments, only: [:new, :create]
    resources :likes, only: [:create, :destroy]
  end

  resources :links, only: [:show, :new, :create] do
    resources :comments, only: [:new, :create]
    resources :likes, only: [:create, :destroy]
  end

  root 'home#show'
end
