class SensorsController < ApplicationController
  include ActionController::Live

  def index
    @proximity_count = Sensors::SensorsManager.instance.sensor_count(Sensors::SensorsManager::PROXIMITY_SENSOR)
    @vibration_count = Sensors::SensorsManager.instance.sensor_count(Sensors::SensorsManager::VIBRATION_SENSOR)
  end

  def poll_update
    @proximity_count = Sensors::SensorsManager.instance.sensor_count(Sensors::SensorsManager::PROXIMITY_SENSOR)
    @vibration_count = Sensors::SensorsManager.instance.sensor_count(Sensors::SensorsManager::VIBRATION_SENSOR)

    values = {
        proximity: @proximity_count,
        vibration: @vibration_count
    }

    render json: values
  end

  def update
    setting_name = params['setting_name']
    setting_value = params['setting_value']
    if params['data_type'] == 'toggle'
      setting_value = setting_value.include?('active')
    end

    if setting_name == 'sensor_led'
      Pi::PiManager.instance.turn_led(setting_value ? :on : :off)
    end

    render plain: "ok", status: :ok
  end

end
