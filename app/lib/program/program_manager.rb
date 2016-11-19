module Program
  class ProgramManager

    attr_accessor :program

    def initialize
      program_name = ProgramController.find_or_create_setting_value(Setting::NAME_CURR_PROGRAM_NAME, 'timelapse')

      @program = Program::ProgramFactory.instance(program_name)
    end

    def current_program
      @program
    end

  end
end
