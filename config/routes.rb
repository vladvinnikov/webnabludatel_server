Watcher::Application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  root :to => "home#index"

  namespace :admin do
    resources :watcher_referals, :only => [] do
      collection do
        get :moderate
      end
      member do
        post :approve
        post :reject
        post :problem
      end
    end
  end
end
