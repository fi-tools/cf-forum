Rails.application.routes.draw do
  resources :authors, :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "nodes#index"
  
  get '/new', to: 'nodes#new', as: 'new_node'
  get '/edit/:id', to: 'content_versions#new', as: 'edit_node'
  get '/comment/reply_to', to: 'nodes#new_comment', as: 'reply_to_node'
  
  post '/nodes', to: "nodes#create", as: "nodes"

  get '/:id', to: 'nodes#show', as: 'node'
end
