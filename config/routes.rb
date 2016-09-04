Rails.application.routes.draw do
  namespace :api do
    resources :contacts, only: [:index]
  end
end
