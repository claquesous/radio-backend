Rails.application.routes.draw do
  scope :api, defaults: {format: :json} do
    constraints format: :json do
      post 'login', to: 'auths#create'
      delete 'logout', to: 'auths#destroy'

      resources :users, only: [:create]
      resources :plays, only: [:index, :show]
      resources :songs, except: [:new, :edit, :destroy] do
        member do
          get :similar
          get :credits
        end
      end
      resources :albums, :artists, except: [:new, :edit]
      resources :streams, except: [:new, :edit] do
        member do
          get :available_songs
          get :new_songs
          post :random_songs
          post :recommendations
        end
        resources :songs, only: :show, module: :streams do
          get :similar, on: :member
        end
        resources :artists, only: :show, module: :streams
        resources :plays, except: [:new, :edit]
        resources :ratings, only: [:create]
        resources :requests, except: [:new, :edit]
        resources :choosers, except: [:new, :edit, :show]
      end
    end
  end

  scope :private do
    post "streams/:stream_id/plays", to: "plays#create"

    get "auth", to: "auths#show"
  end
end
