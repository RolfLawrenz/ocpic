module Sensors
  class SensorsManager

    attr_accessor :sensor_counts

    PROXIMITY_SENSOR = 'proximity'
    VIBRATION_SENSOR = 'vibration'
    SENSORS = [
        PROXIMITY_SENSOR,
        VIBRATION_SENSOR
    ]

    attr_accessor :_instance

    def self.instance
      unless @_instance
        @_instance = self.new
      end
      @_instance
    end

    def initialize
      @sensor_counts = {}
      SENSORS.each do |sensor_name|
        @sensor_counts[sensor_name] = 0
      end
    end

    def sensor_count(sensor_name)
      # TODO
      # @sensor_counts[sensor_name]
      Random.rand(10)
    end

  end
end
