Rails.application.routes.draw do
  devise_for :users
  resources :projects
  resources :users, only: [ :show, :edit, :update ], constraints: { id: /[a-zA-Z0-9\-]+/ }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  root "application#index"

  get "dashboard" => "public_dashboard#index", as: :public_dashboard
  get "charts_test" => "charts_test#index", as: :charts_test

  # Ruta personalizada para proyectos de usuario: /username/projects
  get ":username/projects" => "projects#my_projects", as: :user_projects, constraints: { username: /[a-zA-Z0-9\-_]+/ }

  namespace :admin, as: "admin" do
    get "/" => "dashboard#index", as: ""
    resources :projects
    resources :users
    resources :consent_texts, only: [ :index, :edit, :update ]
    resource :maintenance, controller: "maintenance", only: [] do
      post :toggle, on: :member
    end
  end

  namespace :users do
    get "dashboard" => "dashboard#index", as: :dashboard
  end

  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
  end

  post "consent_banner/accept", to: "consent_banner#accept", as: :accept_consent_banner
end
