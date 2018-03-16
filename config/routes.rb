Rails.application.routes.draw do
  namespace :v1 do
    get '/analyser/:region/:realm/:name', to: 'analyser#show'
    namespace :wow do
      get '/realms/:id', to: 'realmlist#index', as: 'realmlist'
    end
  end
end
