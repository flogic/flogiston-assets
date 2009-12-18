ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :assets
  end
  
  map.resources :assets, :only => :show
end
