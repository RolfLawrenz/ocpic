require 'concurrent'

module Program
  class TimelapseProgram < Program::BaseProgram

    attr_accessor :timer_task

    def run
      prepare_camera

      shooting_mode = ProgramController.find_or_create_setting_value(Setting::NAME_TIMELAPSE_MODE, ProgramController::TIMELAPSE_MODES[0])
      set_time_settings(shooting_mode)

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
        shooting_mode = ProgramController.find_or_create_setting_value(Setting::NAME_TIMELAPSE_MODE, ProgramController::TIMELAPSE_MODES[0])
        adjust_camera_for_light(shooting_mode)
        camera = Camera::CameraManager.instance.camera
        camera.capture_photo

        @photo_count += 1
      end
    end

    private

  end
end
