class ProgramController < ApplicationController

  PROGRAM_NAMES = {
      Timelapse: 'Timelapse',
      Sensors: 'Sensors',
  }

  TIMELAPSE_MODES = {
      Landscape: 'Landscape',
      Macro: 'Macro'
  }

  def index
    @program_name = ProgramController.find_or_create_setting_value(Setting::NAME_CURR_PROGRAM_NAME, PROGRAM_NAMES[0])
    @program_select = []
    PROGRAM_NAMES.each do |k,v|
      @program_select << [v, k]
    end

    @timelapse_mode_value = ProgramController.find_or_create_setting_value(Setting::NAME_TIMELAPSE_MODE, TIMELAPSE_MODES[0])
    @timelapse_mode_select = []
    TIMELAPSE_MODES.each do |k,v|
      @timelapse_mode_select << [v, k]
    end

    @interval_value = ProgramController.find_or_create_setting_value(Setting::NAME_INTERVAL, '10')

    @sensor_proximity_value = ProgramController.find_or_create_setting_value(Setting::NAME_SENSOR_PROXIMITY, "1")
    @sensor_vibration_value = ProgramController.find_or_create_setting_value(Setting::NAME_SENSOR_VIBRATION, "1")
    @sensor_time_between_photos = ProgramController.find_or_create_setting_value(Setting::NAME_SENSOR_TIME_BETWEEN_PHOTOS, "1")

    program_manager = Program::ProgramManager.new
    @running_time = program_manager.current_program.running_time_text
    @photo_count = program_manager.current_program.photo_count
    @start_stop_text = program_manager.current_program.running? ? 'Stop' : 'Start'

    puts "PROGRAM running?=#{program_manager.current_program.running?}"

    render :index
  end

  def self.find_or_create_setting_value(db_name, default_value)
    setting = Setting.where(name: db_name).first
    if setting.nil?
      setting = Setting.create(name: db_name, value: default_value)
    end
    setting.value
  end

  def start_stop_program
    puts "START STOP"
    program_manager = Program::ProgramManager.new

    program_manager.current_program.toggle_start_stop

    redirect_to url_for(controller: :program, action: :index)
  end

  # AJAX methods called when controls hit
  def update
    save_setting('program_name', Setting::NAME_CURR_PROGRAM_NAME)
    save_setting('timelapse_mode', Setting::NAME_TIMELAPSE_MODE)
    save_setting('interval', Setting::NAME_INTERVAL)
    save_setting_with('sensor_proximity', Setting::NAME_SENSOR_PROXIMITY, params['sensor_proximity'].include?('active') ? "1" : "0") if params['sensor_proximity']
    save_setting_with('sensor_vibration', Setting::NAME_SENSOR_VIBRATION, params['sensor_vibration'].include?('active') ? "1" : "0") if params['sensor_vibration']
    save_setting('sensor_time_between_photos', Setting::NAME_SENSOR_TIME_BETWEEN_PHOTOS)

    head :ok
  end

  private

  def save_setting(param_name, db_name)
    save_setting_with(param_name, db_name, params[param_name])
  end

  def save_setting_with(param_name, db_name, value)
    if params[param_name].present?
      setting = Setting.where(name: db_name).first
      setting.value = value
      setting.save
    end
  end

end
