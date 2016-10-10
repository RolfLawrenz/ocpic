class PiController < ApplicationController
  def index

    @current_status = Pi::PiManager.current_status

    puts "CURRENT_STATUS=#{@current_status.inspect}"

    @current_status.keys.each do |key|
      puts key
      @current_status[key].keys.each do |field|
        puts field
      end
    end

  end
end
