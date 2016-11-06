module Program
  class BaseProgram
    include ActionView::Helpers::DateHelper

    attr_accessor :name, :start_time, :end_time, :photo_count

    def initialize(name)
      @name = name
      @photo_count = 0
    end

    def start
      Rails.logger.debug("STARTING PROGRAM #{name}")
      @start_time = Time.now
      @end_time = nil
      run
    end

    def stop
      Rails.logger.debug("STOPPING PROGRAM #{name}")
      @end_time = Time.now
    end

    def run
      raise NotImplementedError
    end

    def toggle_start_stop
      if running?
        stop
      else
        start
      end
    end

    def running?
      @start_time.present? && @end_time.nil?
    end

    def stopped?
      @end_time.present?
    end

    def running_time
      Time.now - @start_time
    end

    def running_time_text
      return "Not Running" if !running?
      time_ago_in_words(@start_time)
    end

    def photos_taken
      @photo_count
    end

    def prepare_camera
      Rails.logger.debug("PREPARE CAMERA")

      program_name = @name.titleize
      if @name == 'timelapse'
        shooting_mode = ProgramController.find_or_create_setting_value(Setting::NAME_TIMELAPSE_MODE, ProgramController::TIMELAPSE_MODES[0])
      else
        shooting_mode = ''
      end

      init_settings = SettingsController.start_settings(program_name, shooting_mode)
      new_settings = init_settings.each_with_object({}) { |i, n| n[i[:name]] = i[:value] }

      camera = Camera::CameraManager.instance.camera
      camera.set_settings(new_settings, true)
    end
  end
end
