Rails.application.routes.draw do
  root to: 'root#index'

  loaderio_token = ENV['LOADERIO_TOKEN']

  if loaderio_token.present?
    get "/#{loaderio_token}", to: proc { [200, {}, [loaderio_token]] }
  end

  namespace :api do
    resources :contacts, only: [:index, :show] do
      member do
        patch action: :update
      end
    end
  end
end
