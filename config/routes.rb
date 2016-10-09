Rails.application.routes.draw do
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
