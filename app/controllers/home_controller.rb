class HomeController < ApplicationController
  def index
  end

  def home_shutdown_pi
    PiManager.shutdown
  end

end
