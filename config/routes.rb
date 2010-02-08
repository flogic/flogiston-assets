ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :assets
  end
  
  map.asset '/assets/*id', :controller => 'assets', :action => 'show'
end
