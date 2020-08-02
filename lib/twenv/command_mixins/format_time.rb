module TWEnv::Command::FormatTime
  FormatNotFoundError = Class.new(RuntimeError)

  TIME_FORMATS = {
    upcase: "%d %^B %Y, %H:%M:%S (%Z)"
  }

  def format_time(time, format)
    format_string = TIME_FORMATS[format]
    if format_string.nil?
      raise FormatNotFoundError,
            "No time format by the name '#{format}' found"
    end
    if String === time
      time = Time.parse(time)
    end
    time.strftime(format_string)
  end
end
