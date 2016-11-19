class OperatingSystem

  def self.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def self.unix?
    !self.windows?
  end

  def self.linux?
    self.unix? and not self.mac?
  end

  def self.name
    RUBY_PLATFORM
  end

  def self.type
    return :windows if windows?
    return :mac if mac?
    return :unix if unix?
    return :linux if linux?
    return :unknown
  end

  def self.prepare_os
    if CameraPi::OperatingSystem.mac?
      puts("Kill PTPCamera")
      system 'killall PTPCamera'
    end
  end

end
