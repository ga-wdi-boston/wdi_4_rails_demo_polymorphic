Rails.application.routes.draw do
  devise_for :users

  resources :statuses, only: [:show, :new, :create] do
    resources :comments, only: [:new, :create]
  end

  resources :links, only: [:show, :new, :create] do
    resources :comments, only: [:new, :create]
  end

  root 'home#show'
end
