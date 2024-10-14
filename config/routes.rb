Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  resources :pokemons, only: %i[index destroy] do
    member do
      post 'capture'
    end
    collection do
      get 'captured'
      post 'import'
    end
  end
end
