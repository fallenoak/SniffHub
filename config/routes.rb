Rails.application.routes.draw do
  root 'welcome#index'

  # Uploads
  post '/uploads/authorize'
  post '/uploads/complete'

  # Sessions
  get '/login', to: 'sessions#new'
  post '/sessions', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # Registrations
  get '/register', to: 'registrations#new'
  post '/registrations', to: 'registrations#create'
end
