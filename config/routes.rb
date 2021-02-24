Rails.application.routes.draw do
  mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  devise_for :users do
    get "/sign_out" => "devise/sessions#destroy"
  end
  resources :authors, :path => "a"
  resources :users, :path => "u"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "nodes#index"

  get "/new", to: "nodes#new", as: "new_node"
  get "/edit/:id", to: "content_versions#new", as: "edit_node"
  # todo: can we deprecate /comment/reply_to ?
  get "/comment/reply_to", to: "nodes#new_comment", as: "reply_to_node"

  get "/users/authors", to: "authors#mine", as: "edit_user_authors"

  post "/nodes", to: "nodes#create", as: "nodes"
  get "/subtree/:id", to: "nodes#subtree", as: "subtree"

  get "/:id", to: "nodes#show", as: "node"
  get "/focus/:node/on/:id", to: "nodes#focus", as: "focus"

  get "/view_as/:view_name/:id", to: "nodes#view_as", as: "view_as"
end
