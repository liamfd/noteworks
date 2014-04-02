Noteweb::Application.routes.draw do
  get "works/:id/takenotes", to: "works#takenotes", as: 'work'
  get "works/:id/testnetwork", to: "works#testnetwork"
  
  get "works/:id/mod_element", to: "works#mod_element"
  get "works/:id/add_element", to: "works#add_element"
  get "works/:id/del_element", to:"works#del_element"

  patch "works/:id", to: "works#updatenotes"
  resources :works

  get "node/index"
  resources :nodes

  devise_for :users
  resources :users, only: [:show]
  get 'profile', to: 'users#show'

  resources :categories

  #get "categories", to: "categories#index"
  #get '/category/:id', :to => 'categories#show'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
