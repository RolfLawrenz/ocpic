module Pi
  class PiManager

    attr_accessor :_instance

    SHUTDOWN_PIN = 4
    LED_PIN = 18

    DIP1_PIN = 5
    DIP2_PIN = 6
    DIP3_PIN = 13
    DIP4_PIN = 19

    PROXIMITY_SENSOR_PIN = 7
    VIBRATION_SENSOR_PIN = 23

    def self.instance
      unless @_instance
        @_instance = self.new
      end
      @_instance
    end

    def initialize
      init_pin(LED_PIN, 'out')
      #@led_pin  = PiPiper::Pin.new(:pin => LED_PIN, :direction => :out)
      #@dip1_pin = PiPiper::Pin.new(:pin => DIP1_PIN, :direction => :in, :pull => :down)
      #@dip2_pin = PiPiper::Pin.new(:pin => DIP2_PIN, :direction => :in, :pull => :down)
      #@dip3_pin = PiPiper::Pin.new(:pin => DIP3_PIN, :direction => :in, :pull => :down)
      #@dip4_pin = PiPiper::Pin.new(:pin => DIP4_PIN, :direction => :in, :pull => :down)
      #@proximity_sensor_pin = PiPiper::Pin.new(:pin => PROXIMITY_SENSOR_PIN, :direction => :in, :pull => :down)
      #@vibration_sensor_pin = PiPiper::Pin.new(:pin => VIBRATION_SENSOR_PIN, :direction => :in, :pull => :down)
    end

    # See GPIO manual. Direction can be in/out/pwm/clock/up/down/tri
    def init_pin(pin_num, direction)
      system("gpio -g mode #{pin_num} #{direction}")
    end

    def pin_on?(pin_num)
      val = %x[gpio -g read #{pin_num}]
      Rails.logger.debug "PIN #{pin_num} on? val=#{val}"
      val == '1'
    end

    def proximity_sensor_on?
      pin_on?(PROXIMITY_SENSOR_PIN)
    end

    def vibration_sensor_on?
      pin_on?(VIBRATION_SENSOR_PIN)
    end

    # Either (:on, :off)
    def turn_led(value)
      cmd = "gpio -g write #{LED_PIN} #{value == :on ? '1' : '0'}"
      Rails.logger.debug("CMD=#{cmd}")
      val = %x[#{cmd}]
    end

    def shutdown
      Rails.logger.debug("Shutting down Pi...")
      system("sudo shutdown -h now")
    end

    # Looks at the current status of the pi like a 'top' command and more
    def current_status
      if OperatingSystem.mac?
        return { os: {mac: 'mac' }}
      end

      if OperatingSystem.linux?
        top = %x(top -b -n 1)
        load_averages = top.split("\n")[0].partition("load average:")[2].strip.split(", ")
        puts "Load last 1 minute:   #{load_averages[0]}"
        puts "Load last 5 minutes:  #{load_averages[1]}"
        puts "Load last 15 minutes: #{load_averages[2]}"
        uptime = top.split("\n")[0].split(", ")[0].partition("up")[2].strip+','+top.split("\n")[0].split(", ")[1]
        puts "Uptime: #{uptime}"
        user_sessions = top.split("\n")[0].split(", ")[2].strip.to_i
        cpu = 100.0 - top.split("\n")[2].split(', ')[3].to_f
        puts "Current User sessions: #{user_sessions}"
        puts "#{top.split("\n")[1]}"
        puts "% CPU (user processes):   #{top.split("\n")[2].split(', ')[0].partition(":")[2]}"
        puts "% CPU (system processes): #{top.split("\n")[2].split(', ')[1]}"
        puts "% CPU (priority nice):    #{top.split("\n")[2].split(', ')[2]}"
        puts "% CPU (idle):             #{top.split("\n")[2].split(', ')[3]}"
        puts "% CPU (waiting for I/O):  #{top.split("\n")[2].split(', ')[4]}"
        puts "% CPU (hardware interpts):#{top.split("\n")[2].split(', ')[5]}"
        puts "% CPU (software interpts):#{top.split("\n")[2].split(', ')[6]}"
        puts "RAM: #{top.split("\n")[3]}"
        puts "SWAP:#{top.split("\n")[4]}"
        total_memory = top.split("\n")[3].split(' ')[2].to_f
        free_memory = top.split("\n")[3].split(' ')[6].to_f
        free_memory_perc = (free_memory / total_memory * 100).round
        swap_used = top.split("\n")[4].split(', ')[3].to_f

        disk_space = %x(df /tmp --total -k -h)
        puts "Disk Space (Total): #{disk_space.split("\n")[-1].partition("total")[2].split[0]}"
        puts "Disk Space (Used):  #{disk_space.split("\n")[-1].partition("total")[2].split[1]}"
        puts "Disk Space (Avail): #{disk_space.split("\n")[-1].partition("total")[2].split[2]}"
        puts "Disk Space (%Used): #{disk_space.split("\n")[-1].partition("total")[2].split[3]}"
        disk_space_used = disk_space.split("\n")[-1].partition("total")[2].split[3].to_i
        puts "---"

        {
          os: {
              up_time: uptime,
              load: load_averages[0],
              cpu: cpu,
              free_memory: free_memory_perc,
              disk_space: disk_space_used,
              swap_used: swap_used,
          }
        }
      end
    end

  end
end
