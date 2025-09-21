Rails.application.routes.draw do
  get 'users/search', to: 'users#search', as: :search_users
  resources :slot_applications_management, only: [:update]
  devise_for :users

  get "dashboard" => "public_dashboard#index", as: :public_dashboard
  get "charts_test" => "charts_test#index", as: :charts_test

  resources :subscription_plans, only: [ :index, :show ]
  resources :subscriptions, only: [ :new, :create, :edit, :update, :destroy ]

  resources :honorary_calculations do
    member do
      get :pdf
    end
    collection do
      post :calculate_preview
    end
  end

  resources :clients do
    resources :interactions, except: [ :index ]
  end

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
    resources :project_slots, only: [:new, :create, :show] do
      resources :slot_applications, only: [:new, :create]
      member do
        get :search_professionals
        post :assign
        delete :unassign
        get :proposals
      end
    end
    
    # Ruta para búsqueda de usuarios via AJAX
    get :search_users, on: :member
  end

  resources :users, only: [ :show, :edit, :update ], constraints: { id: /[a-zA-Z0-9\-]+/ }

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "home#index"

  namespace :admin, as: "admin" do
    get "/" => "dashboard#index", as: ""
    resources :projects do
      resources :project_slots, only: [:new, :create] do
        resources :slot_applications, only: [:new, :create]
      end
    end
    resources :users
    resources :consent_texts, only: [ :index, :edit, :update ]
    resource :maintenance, controller: "maintenance", only: [] do
      post :toggle, on: :member
    end
  end

  namespace :users do
    get "dashboard" => "dashboard#index", as: :dashboard
  end

  get "user/:username/projects" => "projects#my_projects", as: :user_projects, constraints: { username: /[a-zA-Z0-9\-_]+/ }
  get "user/:username/favoritos" => "projects#my_favorites", as: :user_favorites, constraints: { username: /[a-zA-Z0-9\-_]+/ }

  resources :conversations, only: [ :index, :show, :create ] do
    resources :messages, only: [ :create ]
    collection do
      get :test_info
    end
  end

  post "consent_banner/accept", to: "consent_banner#accept", as: :accept_consent_banner

  post 'payments/checkout', to: 'payments#create_checkout_session', as: :payments_checkout
  get 'payments/success', to: 'payments#success', as: :payments_success
  get 'payments/cancel', to: 'payments#cancel', as: :payments_cancel
end









