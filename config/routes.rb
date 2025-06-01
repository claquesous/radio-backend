Rails.application.routes.draw do
  scope :admin do
    get "logout" => "sessions#destroy", :as => "logout"
    get "login" => "sessions#new", :as => "login"
    get "signup" => "users#new", :as => "signup"
    resources :users
    resources :sessions
    resources :streams do
      resources :choosers, except: [:new, :create, :destroy]
      resources :ratings, only: [:create]
      resources :requests, only: [:index, :create, :show]
      resources :plays, only: [:index, :show]
    end

    resources :plays, only: [:index, :show]
    resources :songs, :albums, :artists, except: :destroy

    root 'plays#index'
  end

  scope :api, defaults: {format: :json} do
    constraints format: :json do
      post 'login', to: 'auths#create'
      get 'current_user_profile', to: 'auths#current_user_profile'

      resources :plays, only: [:index, :show]
      resources :songs, :albums, :artists, only: [:index, :show]
      resources :streams, only: [:index, :show] do
        resources :songs, only: :show, module: :streams
        resources :artists, only: :show, module: :streams
        resources :plays, only: [:index, :show]
        resources :ratings, only: [:create, :show]
        resources :requests, only: [:index, :create, :show]
      end
    end
  end

  scope :private do
    post "streams/:stream_id/plays", to: "plays#create"
    resources :plays, only: [:create]

    get "auth", to: "sessions#logged_in"
  end
end
