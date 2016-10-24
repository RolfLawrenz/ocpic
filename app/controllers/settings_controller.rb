class SettingsController < ApplicationController

  TIMELAPSE_SELECTED_SETTINGS = [
      'exposurecompensation',
      # 'f-number',
      'highisonr',
      'iso',
      'longexpnr',
      # 'shutterspeed2'
  ]

  def index
    @timelapse_modes = ProgramController::TIMELAPSE_MODES.values

  end

  def timelapse_mode
    @shooting_mode = params['shooting_mode']
    if Camera::CameraManager.instance.connected?
      @timelapse_settings = {}
      Program::TimelapseProgram::TIME_MODES.each do |time_mode|
        @timelapse_settings[time_mode] = timelapse_settings(@shooting_mode, time_mode)
      end
      render :timelapse_mode
    else
      render "camera/not_connected"
    end

  end

  def timelapse_settings(shooting_mode, time_mode)
    @back_path = settings_index_path
    camera = Camera::CameraManager.instance.camera

    settings = []
    TIMELAPSE_SELECTED_SETTINGS.each do |selected_setting|
      camera_setting = camera.selected_setting(selected_setting)
      settings << {
        name: selected_setting,
        type: camera_setting[:type],
        value: ProgramController.find_or_create_setting_value(setting_db_name(shooting_mode, time_mode, selected_setting), camera_setting[:value]),
        options: camera_setting[:options]
      }
    end
    settings
  end

  def update
    setting_params = params['setting_name'].split('_')
    shooting_mode = setting_params[1]
    time_mode = setting_params[2]
    setting_name = setting_params[3..-1].join
    setting_value = params['setting_value']
    if params['data_type'] == 'toggle'
      setting_value = setting_value.include?('active')
    end

    save_setting_with(setting_db_name(shooting_mode, time_mode, setting_name), setting_value)

    render plain: setting_value, status: status
  end

  private

  def setting_db_name(shooting_mode, time_mode, field_name)
    "setting_timelapse_#{shooting_mode}_#{time_mode}_#{field_name}"
  end

  def save_setting_with(db_name, value)
    setting = Setting.where(name: db_name).first
    puts "SETTING #{db_name}=#{value}"
    setting.value = value
    setting.save
  end


end
