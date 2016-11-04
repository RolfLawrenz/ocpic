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

  end

  private


end
