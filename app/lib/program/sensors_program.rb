module Program
  class SensorsProgram < Program::BaseProgram

    attr_accessor :thread

    # Only allow a change of settings every 10 seconds
    TIME_FOR_CHANGE = 10

    def run
      prepare_camera

      shooting_mode = SettingsController::SENSOR_SHOOTING_MODE
      set_time_settings(shooting_mode)

      @sensor_proximity_value = ProgramController.find_or_create_setting_value(Setting::NAME_SENSOR_PROXIMITY, "1")
      @sensor_vibration_value = ProgramController.find_or_create_setting_value(Setting::NAME_SENSOR_VIBRATION, "1")
      @time_between_photos    = ProgramController.find_or_create_setting_value(Setting::NAME_SENSOR_TIME_BETWEEN_PHOTOS, "1").to_f
 
      # Run loop to trigger on sensors and take photo
      @last_photo_time = Time.now - @time_between_photos
      setting_last_changed = Time.now
      @thread = Thread.new do
        while true do
          sleep(0.1)
          if stopped?
            break
          end

          # Adjust camera settings if needed
          if (Time.now - setting_last_changed) > TIME_FOR_CHANGE
            adjust_camera_for_light(shooting_mode)
            setting_last_changed = Time.now
          end

          # Check if sensors triggered
          if (Time.now - @last_photo_time) >= @time_between_photos
            if (@sensor_proximity_value == '1' && Sensors::SensorsManager.instance.proximity_pin_on?) ||
               (@sensor_vibration_value == '1' && Sensors::SensorsManager.instance.vibration_pin_on?)
              camera = Camera::CameraManager.instance.camera
              @last_photo_time = Time.now
              camera.capture_photo
            end
          end

        end
        Rails.logger.debug("Stopped Sensors Program")
      end

      @thread.run

    end


  end

end
