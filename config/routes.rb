Rails.application.routes.draw do
  resources :choosers
  scope :admin do
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    get "signup" => "users#new", :as => "signup"
    resources :users
    resources :sessions
    resources :streams

    resources :listeners, :requests, :ratings, only: [:index, :show]
    resources :plays, only: [:index, :show]
    resources :songs, :albums, :artists, except: :destroy

    root 'plays#index'
  end

  scope :api, defaults: {format: :json} do
    constraints format: :json do
      resources :listeners, :requests, :ratings, only: [:index, :show]
      resources :plays, only: [:index, :show]
      resources :songs, :albums, :artists, only: [:index, :show]
      resources :streams, only: [:index, :show]
    end
  end

  scope :private do
    resources :plays, only: [:create]

    get "auth", to: "sessions#logged_in"
  end
end
