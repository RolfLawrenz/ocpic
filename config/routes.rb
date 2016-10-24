Rails.application.routes.draw do

  match 'program/index', to: 'program#index', via: [:get, :post]
  post 'program/update'
  get 'program/start_stop_program'

  get 'settings/index'
  get 'settings/timelapse_mode'
  post 'settings/update'

  get 'photos/index'

  get 'sensors/index'
  get 'sensors/poll_update'

  get 'camera/index'
  post 'camera/update'

  get 'pi/index'

  get 'home/index'
  get 'home/shutdown_pi'

  root 'home#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
