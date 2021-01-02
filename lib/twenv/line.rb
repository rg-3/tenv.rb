# frozen_string_literal: true

class TWEnv::Line
  RED_ERROR = Paint["ERR", "#CC0000", :bright]
  GREEN_OK  = Paint["OK", "#00FF00", :bright]
  ORANGE_WARNING = Paint["WARN", "#FFA500", :bright]

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
    print "#{RED_ERROR} #{message[0].upcase}#{message[1..-1]}"
  end

  def ok(message)
    print "#{GREEN_OK} #{message[0].upcase}#{message[1..-1]}"
  end

  def warn(message)
    print "#{ORANGE_WARNING} #{message[0].upcase}#{message[1..-1]}"
  end

  def end
    @io.print "\n"
    self
  end

  def rewind
    @io.print "\b \b" * @size
    self
  end
end
