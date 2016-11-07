class HomeController < ApplicationController
  def index
    @program_name = ProgramController.find_or_create_setting_value(Setting::NAME_CURR_PROGRAM_NAME, 'timelapse').titleize
    program_manager = Program::ProgramManager.new
    @running_time = program_manager.current_program.running_time_text

    camera = Camera::CameraManager.instance.camera
    @photo_count = camera.photo_count
  end

  def home_shutdown_pi
    PiManager.instance.shutdown
  end

end
