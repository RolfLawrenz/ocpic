class ProgramController < ApplicationController

  PROGRAM_NAMES = {
      timelapse: 'Timelapse',
      sensors: 'Sensors',
  }

  TIMELAPSE_MODES = {
      landscape: 'Landscape',
      macro: 'Macro'
  }

  def index

    @program_name = find_or_create_setting_value(Setting::NAME_CURR_PROGRAM_NAME, 'timelapse')
    @program_select = []
    PROGRAM_NAMES.each do |k,v|
      @program_select << [v, k]
    end

    @timelapse_mode_value = find_or_create_setting_value(Setting::NAME_TIMELAPSE_MODE, 'landscape')
    @timelapse_mode_select = []
    TIMELAPSE_MODES.each do |k,v|
      @timelapse_mode_select << [v, k]
    end

    @interval_value = find_or_create_setting_value(Setting::NAME_INTERVAL, '10')

    @sensor_proximity_value = find_or_create_setting_value(Setting::NAME_SENSOR_PROXIMITY, "1")
    @sensor_vibration_value = find_or_create_setting_value(Setting::NAME_SENSOR_VIBRATION, "1")

    render :index
  end

  def find_or_create_setting_value(db_name, default_value)
    setting = Setting.where(name: db_name).first
    if setting.nil?
      setting = Setting.create(name: db_name, value: default_value)
    end
    setting.value
  end

  def update
    save_setting('program_name', Setting::NAME_CURR_PROGRAM_NAME)
    save_setting('timelapse_mode', Setting::NAME_TIMELAPSE_MODE)
    save_setting('interval', Setting::NAME_INTERVAL)
    save_setting_with('sensor_proximity', Setting::NAME_SENSOR_PROXIMITY, params['sensor_proximity'].include?('active') ? "1" : "0") if params['sensor_proximity']
    save_setting_with('sensor_vibration', Setting::NAME_SENSOR_VIBRATION, params['sensor_vibration'].include?('active') ? "1" : "0") if params['sensor_vibration']

    head :ok
  end

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
