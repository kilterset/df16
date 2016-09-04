Rails.application.routes.draw do
  namespace :api do
    resources :contacts, only: [:index, :show] do
      member do
        patch action: :update
      end
    end
  end
end
