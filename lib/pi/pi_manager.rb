module Pi
  class PiManager

    def self.shutdown
    # TODO shutdown pi
    end

    # Looks at the current status of the pi like a 'top' command and more
    def self.current_status
      # TODO Load some real values
      {
        os: {
            up_time: '4 hours 12 mins',
            load: '1.2',
            cpu: '12%',
            free_memory: '40%',
            disk_space: '2.4G',
        },
        nginx: {
          running: 'true',
          up_time: '4 hours',
        }
      }
    end
  end
end
