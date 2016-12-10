module Camera
  class CameraManager

    attr_accessor :_instance, :camera

    def self.instance
      unless @_instance
        @_instance = self.new
      end
      @_instance
    end

    def initialize
      @camera = ::Camera::Camera.new
      # @camera.show_all_settings
    end

    def connected?
      return true if @camera.camera_connected?
      # Try connect again
      @camera = ::Camera::Camera.new
      return @camera.camera_connected?
    end

    def refresh(capture_count)
      @camera.shutdown
      @camera = nil
      @camera = ::Camera::Camera.new(capture_count)
    end

  end
end
