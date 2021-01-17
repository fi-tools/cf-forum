Rails.application.routes.draw do
  devise_for :users
  resources :authors, :path => "a"
  resources :users, :path => "u"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "nodes#index"

  get "/new", to: "nodes#new", as: "new_node"
  get "/edit/:id", to: "content_versions#new", as: "edit_node"
  get "/comment/reply_to", to: "nodes#new_comment", as: "reply_to_node"

  get "/users/authors", to: "authors#mine", as: "edit_user_authors"

  post "/nodes", to: "nodes#create", as: "nodes"
  get "/subtree/:id", to: "nodes#subtree", as: "subtree"

  get "/:id", to: "nodes#show", as: "node"
end
