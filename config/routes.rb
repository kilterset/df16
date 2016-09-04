Rails.application.routes.draw do
  root to: 'root#index'

  namespace :api do
    resources :contacts, only: [:index, :show] do
      member do
        patch action: :update
      end
    end
  end
end
