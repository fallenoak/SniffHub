Rails.application.routes.draw do
  root 'welcome#index'

  post '/uploads/authorize'
  post '/uploads/complete'
end
