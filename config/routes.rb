Rails.application.routes.draw do
  apipie
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  namespace :api do
    namespace :v1 do
      get '/search/:engine/:query', to: 'search#index', as: 'search'
    end
  end
end