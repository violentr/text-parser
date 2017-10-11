Rails.application.routes.draw do
  root "campaigns#index", controller: :campaigns, action: :index
  resources :campaigns
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
