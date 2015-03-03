Rails.application.routes.draw do
  root 'pages#home'

  get  'login', to: 'sessions#new', as: :login
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  get 'dashboard', to: 'dashboard#index'

  resources :users, only: [:create]
  resources :courses, only: [:show] do
    resources :challenges, only: [:show]
  end

  resources :solutions, only: [] do
    post 'submit', on: :member
  end
end
