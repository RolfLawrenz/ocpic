class PiController < ApplicationController
  def index
    @current_status = Pi::PiManager.instance.current_status
  end
end
