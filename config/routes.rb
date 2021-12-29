Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  get '/search/:engine/:query', to: 'search#index', as: 'search'
end