require 'gphoto2'
require 'date'

module Camera
  class Camera

    attr_accessor :camera, :capture_count, :exp_comp_choices, :f_number_choices, :iso_choices

    FOCUS_MODES = {
        manual: "Manual",
        single: "AF-S",
        continuous: "AF-C",
    }

    SET_SETTINGS_RETRY_COUNT = 3
    SAVE_RETRY = 3

    SETTINGS_MENUS_TO_IGNORE = %w(other)

    MENU_FIELDS_DISABLED = [
        'manufacturer',
        'serialnumber',
        'vendorextension',
        'cameramodel',
        'batterylevel',
        'deviceversion',
        'maxfocallength',
        'minfocallength',
        'datetime'
    ]

    def initialize
      @capture_count = 0
      begin
        puts "---------- CONNECTING TO CAMERA -------"
        init_camera
        @exp_comp_choices = field_choices(['capturesettings','exposurecompensation'])
        @f_number_choices = field_choices(['capturesettings','f-number'])
        @iso_choices = field_choices(['imgsettings','iso'])
      rescue Exception => e
        #  No Camera, try again later
        puts "ERROR: #{e.message}"
      end
    end

    def init_camera
      @camera = GPhoto2::Camera.first
    end

    # Settings in the form of:
    # [
    #   { name: <menu name>,
    #     fields: [
    #       name: <field name>
    #       type: <field type>
    #       value: <field value>
    #       options: <field options>
    #     ]
    #   }
    # ]
    def all_settings
      settings = []
      widget = @camera.window

      widget.children.each do |menu|
        next if SETTINGS_MENUS_TO_IGNORE.include?(menu.name)
        menu_fields = []
        menu.children.each do |field|
          case field.type
            when :range
              options = field.range
            when :radio, :menu
              options = field.choices
            else
              options = nil
          end
          field_hash = {
              name: field.name,
              type: field.type,
              value: field.value,
              options: options
          }
          menu_fields << field_hash
        end
        settings << {
            name: menu.name,
            fields: menu_fields
        }
      end
      settings
    end

    def selected_settings(setting_names)
      selected = []
      all_settings.each do |menu|
        menu[:fields].each do |field|
          selected << field if setting_names.include?(field[:name])
        end
      end
      selected
    end

    def selected_setting(setting_name)
      selected_settings([setting_name])[0]
    end

    def camera_connected?
      puts "____ CONNECTED=#{@camera.present?} _____"
      @camera.present?
    end

    # This uses timezone in camera
    def datetime_as_long
      result = %x(gphoto2 --get-config datetime)
      fields = result.split
      index = fields.index('Current:')
      return nil unless index && index > 0
      fields[index + 1]
    end

    # This uses timezone in camera
    def datetime
      result = %x(gphoto2 --get-config datetime)
      fields = result.split("\n")
      fields.each do |field|
        if field.start_with?("Printable")
          date_str = field.partition(':')[2].strip
          return DateTime.strptime(date_str,"%a %b %d %H:%M:%S %Y")
        end
      end
      nil
    end

    # Uses UTC timezone
    def datetime_utc
      @camera['datetime'].value
    end

    def display_fields(widget, level = 0)
      indent = '  ' * level

      puts "#{indent}#{widget.name}"

      if widget.type == :window || widget.type == :section
        widget.children.each { |child| display_fields(child, level + 1) }
        return
      end

      indent << '  '

      puts "#{indent}type: #{widget.type}"
      puts "#{indent}value: #{widget.value}"

      case widget.type
        when :range
          range = widget.range
          step = (range.size > 1) ? range[1] - range[0] : 1.0
          puts "#{indent}options: #{range.first}..#{range.last}:step(#{step})"
        when :radio, :menu
          puts "#{indent}options: #{widget.choices.inspect}"
      end
    end

    def exposure_compensation
      @camera['exposurecompensation'].value
    end

    def increase_field_value(field_name, values)
      field_value = @camera[field_name].value
      index = values.index(field_value)
      Rails.logger.info("increase #{field_name} (#{field_value} to #{values[index+1]})")
      @camera[field_name] = values[index+1]
      save_retry
    end

    def decrease_field_value(field_name, values)
      field_value = @camera[field_name].value
      index = values.index(field_value)
      Rails.logger.info("decrease #{field_name} (#{field_value} to #{values[index-1]})")
      @camera[field_name] = values[index-1]
      save_retry
    end

    def save_retry
      count = 0
      while count < SAVE_RETRY do
        begin
          @camera.save
          break
        rescue
          count += 1
          Rails.logger.info("ERROR Saving - retry #{count}")
        end
      end
    end

    def exposure_program
      @camera['expprogram'].value
    end

    # Value meanings: https://en.wikipedia.org/wiki/Exposure_value
    # 12 - 16  - Daylight
    # 12       - Sunrise / Sunset
    # 5 - 11   - Dusk / Dawn
    # 7 - 8    - Night, bright street
    # 5 - 8    - Inside buildings, artificial light
    # 5        - Night, near lighted buildings
    # 2 - 3    - Night, distant lighted buildings
    # -2       - Night, dark landscape at full moon
    # -4       - Night, dark landscape at half moon
    # -6 - -8  - Night, dark landscape at new moon
    # -3 - -9  - Night, stars
    # -10      - Night, weak celestial bodies, nebulae
    # *** Takes into account exposure compensation
    def ev
      reload
      _iso = iso.to_f
      _shutterspeed = shutterspeed_value
      _f_number = f_number_value.to_f
      _exp_comp = exposure_compensation.to_f

      # EV = log2(100 x f-number^2 / (ISO x shutter))
      Math::log2(100 * (_f_number ** 2) / (_iso * _shutterspeed)) + _exp_comp
    end

    def name
      @camera['cameramodel'].value
    end

    def reload
      @camera.reload
    end

    def shutterspeed
      @camera['shutterspeed2'].value
    end

    def shutterspeed_value
      values = shutterspeed.split("/")
      values.count == 2 ? values[0].to_f / values[1].to_f : values[0].to_f
    end

    def f_number
      @camera['f-number'].value
    end

    def f_number_value
      f_number.split('/')[1]
    end

    def iso
      @camera['iso'].value
    end

    def iso_choice_from_ev
      _ev = ev
      if _ev > 12
        "200"
      elsif _ev > 10
        "400"
      elsif _ev > 7
        "800"
      elsif _ev > 5
        "1000"
      elsif _ev > 3
        "1250"
      else
        "1600"
      end
    end

    def capture_photo
      Rails.logger.info("##{@capture_count} Capture Photo")
      puts("##{@capture_count} Capture Photo")
      @capture_count += 1
      @camera.capture
    end

    def capture_photo_and_download
      capture_photo.save
    end

    def shutdown
      @camera.finalize
    end

    # WARNING: This will open shutter but not close, like for a LV Movie
    def preview
      @camera.preview
    end

    def set_settings(settings)
      return if settings.nil?

      count = 0
      while count < SET_SETTINGS_RETRY_COUNT do
        Rails.logger.debug("set_settings ##{count}")
        begin
          if settings.is_a?(Hash)
            set_settings_hash(settings)
          elsif settings.is_a?(Array)
            settings.each do |stgs|
              set_settings_hash(stgs)
              # Need to wait at least 3 seconds here for settings to take effect
              sleep(4)
            end
          end
          break
        rescue
          count += 1
          Rails.logger.error("set settings FAILED - retry")
          raise "SETTINGS ERROR" if count == SET_SETTINGS_RETRY_COUNT
        end
      end
    end

    def field_choices(field_tree)
      widget = @camera.window
      field_tree.each do |field|
        widget = widget.children.select{|c| c.name == field }[0]
      end
      widget.choices
    end

    def show_all_settings
      widget = @camera.window
      display_fields(widget)
    end

    def photo_count
      photo_files(@camera.filesystem).count
    end

    def photo_files(folder = @camera.filesystem)
      folder_files = []
      folder.files.each do |file|
        # puts "..file=#{file.inspect}"
        folder_files << file
      end
      folder.folders.each do |child_folder|
        # puts "__child_folder=#{folder.inspect}"
        folder_files += photo_files(child_folder)
      end
      folder_files
    end

    def download_thumbs(dest_folder)
      puts "DOWNLOAD THUMBS to #{dest_folder}"
      FileUtils.mkdir_p(dest_folder) unless File.directory?(dest_folder)

      # Need to loose connection to camera so can use this command line gphoto2 task
      shutdown

      system("cd #{dest_folder};gphoto2 --get-all-thumbnails --skip-existing;cd -")

      # Take control of camera again
      init_camera
    end

    private

    def set_settings_hash(settings)
      settings.each do |setting, value|
        Rails.logger.info("  #{setting}: #{value}")
        @camera[setting] = value
      end
      Rails.logger.info("save settings")
      @camera.save
    end

  end
end
