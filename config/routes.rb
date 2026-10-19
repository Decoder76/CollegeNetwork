Rails.application.routes.draw do
  resources :conversations, only: %i[index show new create] do
    resources :messages, only: %i[create update destroy]
    post :invitations, to: "conversation_invitations#create"
    patch "invitations/:invitation_id", to: "conversation_invitations#update", as: :invitation
    post :leave_requests, to: "conversation_leave_requests#create"
    patch "leave_requests/:leave_request_id", to: "conversation_leave_requests#update", as: :leave_request
  end
  get "invitations", to: "conversation_invitations#index", as: :invitations
  patch "invitations/:id", to: "conversation_invitations#respond", as: :respond_to_invitation
  resources :connections, only: %i[index create update destroy]
  resources :posts
  resources :profiles
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "posts#index"
end
