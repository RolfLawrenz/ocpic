class SensorsController < ApplicationController
  include ActionController::Live

  def index
    @proximity_count = Sensors::SensorsManager.instance.sensor_count(Sensors::SensorsManager::PROXIMITY_SENSOR)
    @vibration_count = Sensors::SensorsManager.instance.sensor_count(Sensors::SensorsManager::VIBRATION_SENSOR)
  end

  def poll_update
    puts "POLL_UPDATE"
    @proximity_count = Sensors::SensorsManager.instance.sensor_count(Sensors::SensorsManager::PROXIMITY_SENSOR)
    @vibration_count = Sensors::SensorsManager.instance.sensor_count(Sensors::SensorsManager::VIBRATION_SENSOR)

    values = {
        proximity: @proximity_count,
        vibration: @vibration_count
    }

    render json: values
  end
end
