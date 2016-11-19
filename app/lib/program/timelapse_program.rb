require 'concurrent'

module Program
  class TimelapseProgram < Program::BaseProgram

    attr_accessor :timer_task

    TIME_MODES = [
        'day',
        'dusk',
        'night'
    ]

    def run
      prepare_camera
      set_timelapse_settings

      @photo_count = 0

      @timer_task.shutdown if @timer_task.present?

      timelapse_interval = Setting.where(name: Setting::NAME_INTERVAL).first
      Rails.logger.debug("INTERVAL=#{timelapse_interval.value}")

      @timer_task = Concurrent::TimerTask.new(run_now: true, execution_interval: timelapse_interval.value.to_i, timeout_interval: timelapse_interval.value.to_i) do |task|

        timer_action(task)
      end

      @timer_task.execute
    end

    def timer_action(task)
      puts("TIMER ACTION exec_int=#{task.execution_interval} count=#{@photo_count}")
      if stopped?
        puts 'Stopping...'
        task.shutdown
      else
        # adjust_camera_for_light
        camera = Camera::CameraManager.instance.camera
        camera.capture_photo

        @photo_count += 1
      end
    end

    private

    # Return what the current time mode is based on current light reading in camera
    def current_time_mode
      camera = Camera::CameraManager.instance.camera
      ev = camera.ev
      if ev < 5
        return TIME_MODES[2]
      elsif ev < 12
        return TIME_MODES[1]
      else
        return TIME_MODES[0]
      end
    end

    def set_timelapse_settings
      Rails.logger.debug("SET TIMELAPSE SETTINGS")
      shooting_mode = ProgramController.find_or_create_setting_value(Setting::NAME_TIMELAPSE_MODE, ProgramController::TIMELAPSE_MODES[0])

      timelapse_settings = SettingsController.timelapse_settings(shooting_mode, current_time_mode)
      new_settings = timelapse_settings.each_with_object({}) { |i, n| n[i[:name]] = i[:value] }

      camera = Camera::CameraManager.instance.camera
      camera.set_settings(new_settings)
    end

  end
end
