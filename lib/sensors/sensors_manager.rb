module Sensors
  class SensorsManager

    attr_accessor :_instance, :sensor_counts

    PROXIMITY_SENSOR = 'proximity'
    VIBRATION_SENSOR = 'vibration'
    SENSORS = [
        PROXIMITY_SENSOR,
        VIBRATION_SENSOR
    ]

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
      case sensor_name
        when Sensors::SensorsManager::PROXIMITY_SENSOR
          @sensor_counts[sensor_name] += 1 if proximity_pin_on?
        when Sensors::SensorsManager::VIBRATION_SENSOR
          @sensor_counts[sensor_name] += 1 if vibration_pin_on?
      end
      @sensor_counts[sensor_name]
    end

    def proximity_pin_on?
      Pi::PiManager.instance.proximity_sensor_on?
    end

    def vibration_pin_on?
      Pi::PiManager.instance.vibration_sensor_on?
    end

  end
end
