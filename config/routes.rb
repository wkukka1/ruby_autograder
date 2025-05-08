Rails.application.routes.draw do
  resources :submissions, only: [:create, :show]
end
