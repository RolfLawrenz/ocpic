module Program
  class ProgramFactory
    attr_accessor :instances

    def self.instance(program_name)
      @instances ||= {}
      instance = @instances[program_name]
      unless instance
        instance = create_program(program_name)
        @instances[program_name] = instance
      end
      instance
    end

    private

    def self.create_program(program_name)
      Object.const_get("Program").const_get("#{program_name.camelize}Program").new(program_name)
    end
  end

end