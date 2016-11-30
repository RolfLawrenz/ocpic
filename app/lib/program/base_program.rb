module Program
  class BaseProgram
    include ActionView::Helpers::DateHelper

    attr_accessor :name, :start_time, :end_time, :photo_count

    TIME_MODES = [
        'day',
        'dusk',
        'night'
    ]

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

      @photo_count = 0

      program_name = @name.titleize
      if @name == ProgramController::PROGRAM_NAMES[:Timelapse]
        shooting_mode = ProgramController.find_or_create_setting_value(Setting::NAME_TIMELAPSE_MODE, ProgramController::TIMELAPSE_MODES[0])
      else
        shooting_mode = SettingsController::SENSOR_SHOOTING_MODE
      end

      init_settings = SettingsController.start_settings(program_name, shooting_mode)
      new_settings = init_settings.each_with_object({}) { |i, n| n[i[:name]] = i[:value] }

      camera = Camera::CameraManager.instance.camera
      camera.set_settings(new_settings, true)
    end

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

    def program_str
      name
    end

    def set_time_settings(shooting_mode)
      Rails.logger.debug("SET TIME SETTINGS - #{current_time_mode}")
      time_settings = SettingsController.time_settings(shooting_mode, current_time_mode, program_str)
      new_settings = time_settings.each_with_object({}) { |i, n| n[i[:name]] = i[:value] }

      camera = Camera::CameraManager.instance.camera
      camera.set_settings(new_settings)
    end

    def adjust_camera_for_light(shooting_mode)
      puts "adjusting.."
      camera = Camera::CameraManager.instance.camera
      time_settings = SettingsController.time_settings(shooting_mode, current_time_mode, program_str)

      time_settings.each do |setting|
        setting_name = setting[:name]
        setting_value = setting[:value]
        setting_options = setting[:options]

        next if setting_value.blank?

        camera_value = camera.camera[setting_name].value
        next if setting_value == camera_value

        setting_index = setting_options.index(setting_value)
        camera_index = setting_options.index(camera_value)

        puts "setting_index=#{setting_index} camera_index=#{camera_index}"

        Rails.logger.debug("CHANGE #{setting_name} camera:#{camera_value} setting:#{setting_value}")
        if setting_index < camera_index
          camera.decrease_field_value(setting_name, setting_options)
        elsif setting_index > camera_index
          camera.increase_field_value(setting_name, setting_options)
        end
      end
    end

    def field_index_of(options, value)
      options.index(value)
    end

  end
end
