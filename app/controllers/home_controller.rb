class HomeController < ApplicationController
  def index
    @program_name = ProgramController.find_or_create_setting_value(Setting::NAME_CURR_PROGRAM_NAME, ProgramController::PROGRAM_NAMES[0]).titleize
    program_manager = Program::ProgramManager.new
    @running_time = program_manager.current_program.running_time_text

    if Camera::CameraManager.instance.connected?
      camera = Camera::CameraManager.instance.camera
      @photo_count = camera.photo_count
      @camera_active = true
    else
      @photo_count = 0
      @camera_active = false
    end

  end

  def shutdown_pi
    ::PiManager.instance.shutdown
  end

end
