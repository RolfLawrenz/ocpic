class CameraController < ApplicationController
  def index
    if Camera::CameraManager.instance.connected?
      camera = Camera::CameraManager.instance.camera

      @all_settings = camera.all_settings

      render :index
    else
      render :not_connected
    end
  end

  def update
    setting_name = params['setting_name'].gsub('field_','')
    setting_value = params['setting_value']
    if params['data_type'] == 'toggle'
      setting_value = setting_value.include?('active')
    end

    return_str = ""
    begin
      camera = Camera::CameraManager.instance.camera
      camera.set_settings({setting_name => setting_value})

      value = camera.camera[setting_name].to_s
      if (value.to_s == setting_value.to_s)
        status = :ok
        return_str = value
      else
        status = :forbidden
        return_str = setting_name
      end
    rescue
      return_str = setting_name
      status = :bad_request
    end

    render plain: return_str, status: status
  end

  def take_photo
    Rails.logger.debug("TAKE PHOTO")
    camera = Camera::CameraManager.instance.camera
    camera.capture_photo

    render plain: "ok", status: :ok
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
