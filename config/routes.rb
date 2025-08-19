Rails.application.routes.draw do
  devise_for :users

  # Rutas específicas antes de la ruta genérica de usuarios
  get "dashboard" => "public_dashboard#index", as: :public_dashboard
  get "charts_test" => "charts_test#index", as: :charts_test

  # Rutas de suscripciones
  resources :subscription_plans, only: [ :index, :show ]
  resources :subscriptions, only: [ :new, :create, :edit, :update, :destroy ]

  # Rutas de calculadora de honorarios
  resources :honorary_calculations do
    member do
      get :pdf
    end
    collection do
      post :calculate_preview
    end
  end

  # Rutas de CRM
  resources :clients do
    resources :interactions, except: [ :index ]
  end

  # Rutas de gestión de proyectos (unificadas)
  get "proyectos" => "projects#management", as: :management_projects

  # Rutas de facturación
  resources :invoices, path: "facturas" do
    member do
      get :factura, action: :pdf
      patch :mark_as_sent
      patch :mark_as_paid
    end
  end

  resources :projects do
    resources :project_favorites, only: [ :create, :destroy ], path: "favorites"
    resources :documents, except: [ :edit, :update ] do
      member do
        get :download
      end
    end

    resources :project_tasks, except: [ :show ] do
      member do
        patch :update_progress
        patch :change_status
      end
    end

    resources :project_milestones, except: [ :show ] do
      member do
        patch :mark_completed
        patch :mark_cancelled
      end
    end

    member do
      get :timeline
      get :gantt_data
    end
  end
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

  # Ruta personalizada para proyectos de usuario: /username/projects
  get ":username/projects" => "projects#my_projects", as: :user_projects, constraints: { username: /[a-zA-Z0-9\-_]+/ }

  # Ruta personalizada para favoritos de usuario: /username/favoritos
  get ":username/favoritos" => "projects#my_favorites", as: :user_favorites, constraints: { username: /[a-zA-Z0-9\-_]+/ }

  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
    collection do
      get :test_info
    end
  end

  post "consent_banner/accept", to: "consent_banner#accept", as: :accept_consent_banner
end
