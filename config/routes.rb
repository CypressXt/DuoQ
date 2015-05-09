Rails.application.routes.draw do

  root 'welcome#index'

  
  get '/user/:id/validate/:token' => 'app_users#confirmation' , as: :confirmation
  get '/user/:id/validate_once_again' => 'app_users#resend_mail' , as: :validation

  resources :user, :as => :app_users, :controller => "app_users", :except => [:destroy] do
    resources :summoners, :except => [:show]
    resources :teams do
      get 'refresh_team_matches' => 'teams#refresh_team_matches', as: :refresh_team_matches
      resources :matches, :except => [:new, :create]
    end
    get 'refresh_teams' => 'teams#refresh_teams'
    post '/summoners/create_token' => 'summoners#create_token'
  end
  
  get 'ask_new_password' => 'password_reset#new', as: :new_reset_password
  post 'new_password' => 'password_reset#create', as: :reset_password
  
  get 'change_log' => 'changes_log#get_commits'
  get 'login' => 'sessions#new'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

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
