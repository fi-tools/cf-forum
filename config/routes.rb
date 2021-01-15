Rails.application.routes.draw do
  get 'archives/index'
  resources :nodes, :authors, :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "nodes#index"
  get '/:id', to: 'nodes#show'
end
