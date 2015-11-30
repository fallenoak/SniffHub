Rails.application.routes.draw do
  root 'welcome#index'

  # Captures
  get '/captures', to: 'captures#index'
  get '/captures/:id', to: 'captures#show'

  # Uploads
  get '/uploads', to: 'uploads#index'
  post '/uploads/authorize', to: 'uploads#authorize'
  post '/uploads/complete', to: 'uploads#complete'
  get '/uploads/:id', to: 'uploads#show'

  # Sessions
  get '/login', to: 'sessions#new'
  post '/sessions', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  # Registrations
  get '/register', to: 'registrations#new'
  post '/registrations', to: 'registrations#create'
end
