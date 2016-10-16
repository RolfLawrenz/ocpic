class PiController < ApplicationController
  def index
    @current_status = Pi::PiManager.current_status
  end
end
