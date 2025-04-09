Rails.application.routes.draw do
  devise_for :users
  devise_for :users, path: '', path_names: {
  sign_in: 'login',
  sign_out: 'logout',
  registration: 'signup'
}

  get "likes/create"
  get "likes/destroy"
  get "comments/create"
  get "comments/destroy"
  

  # Posts with nested comments and likes
  resources :posts do
    resources :comments, only: [:create, :destroy]
    resources :likes, only: [:create, :destroy]
  end

  # Profiles nested under users
  resources :users do
    resource :profile, only: [:show, :edit, :update]
  end

  # Direct messaging system
  resources :messages, only: [:index, :show, :create, :destroy]

  # PWA support (optional)
  get "manifest" => "pwa#manifest", as: :pwa_manifest
  get "service-worker" => "pwa#service_worker", as: :pwa_service_worker

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "posts#index"
end

