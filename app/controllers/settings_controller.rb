class SettingsController < ApplicationController

  TIME_SELECTED_SETTINGS = [
      'exposurecompensation',
      'expprogram',
      'f-number',
      'highisonr',
      'iso',
      'longexpnr',
      'shutterspeed2'
  ]

  PROGRAM_START_SETTINGS = [
      'aelocked',
      'af-area-illumination',
      'afbeep',
      'aflocked',
      'assistlight',
      'autofocusarea',
      'autofocusmode2',
      'autoiso',
      'bracketing',
      'capturemode',
      'capturetarget',
      'centerweightsize',
      'colorspace',
      'dlighting',
      'exposurecompensation',
      'exposuremetermode',
      'expprogram',
      'externalflash',
      'f-number',
      'flashcommandchannel',
      'flashcommandselfcompensation',
      'flashcommandselfmode',
      'flashcommandselfvalue',
      'flashmode',
      'flashopen',
      'flashshutterspeed',
      'flashsyncspeed',
      'focusmetermode',
      'focusmode',
      'highisonr',
      'imagequality',
      'imagesize',
      'iso',
      'isoautohilimit',
      'longexpnr',
      'microphone',
      'minimumshutterspeed',
      'nikonflashmode',
      'rawcompression',
      'recordingmedia',
      'shutterspeed2',
      'whitebalance',
  ]

  TIMELAPSE_STR = ProgramController::PROGRAM_NAMES[:Timelapse]
  SENSORS_STR = ProgramController::PROGRAM_NAMES[:Sensors]

  SENSOR_SHOOTING_MODE = 'Normal'

  def index
    @timelapse_modes = ProgramController::TIMELAPSE_MODES.values

  end

  def timelapse_mode
    @shooting_mode = params['shooting_mode']
    @back_path = settings_index_path
    if Camera::CameraManager.instance.connected?
      @time_settings = {}
      Camera::Camera::TIME_MODES.each do |time_mode|
        @time_settings[time_mode] = SettingsController.time_settings(@shooting_mode, time_mode, TIMELAPSE_STR)
      end
      render :timelapse_mode
    else
      render "camera/not_connected"
    end
  end

  def timelapse_start
    @shooting_mode = params['shooting_mode']
    @back_path = settings_index_path
    if Camera::CameraManager.instance.connected?
      @start_settings = SettingsController.start_settings(TIMELAPSE_STR, @shooting_mode)
      render :timelapse_start
    else
      render "camera/not_connected"
    end
  end

  def sensors_start
    @shooting_mode = SENSOR_SHOOTING_MODE
    @back_path = settings_index_path
    if Camera::CameraManager.instance.connected?
      @start_settings = SettingsController.start_settings(SENSORS_STR, @shooting_mode)
      render :sensors_start
    else
      render "camera/not_connected"
    end
  end

  def sensors_time
    @shooting_mode = SENSOR_SHOOTING_MODE
    @back_path = settings_index_path
    if Camera::CameraManager.instance.connected?
      @time_settings = {}
      Camera::Camera::TIME_MODES.each do |time_mode|
        @time_settings[time_mode] = SettingsController.time_settings(@shooting_mode, time_mode, SENSORS_STR)
      end
      render :sensors_time
    else
      render "camera/not_connected"
    end
  end

  def self.time_settings(shooting_mode, time_mode, program_str)
    camera = Camera::CameraManager.instance.camera

    settings = []
    TIME_SELECTED_SETTINGS.each do |selected_setting|
      camera_setting = camera.selected_setting(selected_setting)
      settings << {
        name: selected_setting,
        type: camera_setting[:type],
        value: ProgramController.find_or_create_setting_value(setting_db_name(program_str, shooting_mode, time_mode, selected_setting), ''),
        options: camera_setting[:options]
      }
    end
    settings
  end

  def self.start_settings(program, shooting_mode)
    camera = Camera::CameraManager.instance.camera

    settings = []
    PROGRAM_START_SETTINGS.each do |selected_setting|
      camera_setting = camera.selected_setting(selected_setting)
      settings << {
        name: selected_setting,
        type: camera_setting[:type],
        value: ProgramController.find_or_create_setting_value(setting_db_name(program, shooting_mode, "start", selected_setting), ''),
        options: camera_setting[:options]
      }
    end
    settings
  end

  def update
    setting_params = params['setting_name'].split('_')
    program = setting_params[1]
    shooting_mode = setting_params[2]
    time_mode = setting_params[3]
    setting_name = setting_params[4..-1].join
    setting_value = params['setting_value']
    if params['data_type'] == 'toggle'
      setting_value = setting_value.include?('active')
    end

    save_setting_with(SettingsController.setting_db_name(program, shooting_mode, time_mode, setting_name), setting_value)

    render plain: setting_value, status: status
  end

  private

  def self.setting_db_name(program, shooting_mode, time_mode, field_name)
    "setting_#{program}_#{shooting_mode}_#{time_mode}_#{field_name}"
  end

  def save_setting_with(db_name, value)
    setting = Setting.where(name: db_name).first
    puts "SETTING #{db_name}=#{value}"
    setting.value = value
    setting.save
  end

end
