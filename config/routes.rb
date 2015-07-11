Rails.application.routes.draw do
  resources :listeners, :requests, :ratings, only: [:index, :show]
  resources :plays, only: [:index, :create, :show]
  resources :songs, :albums, :artists, except: :destroy

  scope :public, defaults: {format: :json} do
    constraints format: :json do
      resources :listeners, :requests, :ratings, only: [:index, :show]
      resources :plays, only: [:index, :show]
      resources :songs, :albums, :artists, only: [:index, :show]
    end
  end

  root 'plays#index'
end
