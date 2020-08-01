# frozen_string_literal: true

class TWEnv::Line
  DESTRUCTIVE_BACKSPACE = "\b \b"
  RED_ERROR_TEXT = Paint["ERR", "#CC0000", :bright]
  GREEN_OK_TEXT  = Paint["OK", "#00FF00", :bright]
  ORANGE_WARNING_TEXT = Paint["WARN", "#FFA500", :bright]

  def initialize(io)
    @io = io
    @size = 0
  end

  def puts(str)
    print(str).end
  end

  def print(str)
    str   = str.gsub(/[\n]*/, '')
    @size = str.size
    @io.print str
    self
  end

  def error(message)
    print "#{RED_ERROR_TEXT} #{message.capitalize}"
  end

  def ok(message)
    print "#{GREEN_OK_TEXT} #{message.capitalize}"
  end

  def warn(message)
    print "#{ORANGE_WARNING_TEXT} #{message.capitalize}"
  end

  def end
    @io.print "\n"
    self
  end

  def rewind
    @io.print Array.new(@size) { DESTRUCTIVE_BACKSPACE }.join
    self
  end
end
