Rails.application.routes.draw do

  match 'program/index', to: 'program#index', via: [:get, :post]
  post 'program/update'
  get 'program/start_stop_program'

  get 'settings/index'

  get 'photos/index'

  get 'sensors/index'

  get 'camera/index'

  get 'pi/index'

  get 'home/index'
  get 'home/shutdown_pi'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
