# frozen_string_literal: true

class TWEnv::Line
  DESTRUCTIVE_BACKSPACE = "\b \b"

  def initialize(io)
    @io = io
    @size = 0
  end

  def puts(str)
    print(str).end_line
  end

  def print(str)
    str   = str.gsub(/[\n]*/, '')
    @size = str.size
    @io.print str
    self
  end

  def end_line
    @io.print "\n"
    self
  end

  def rewind
    @io.print Array.new(@size) { DESTRUCTIVE_BACKSPACE }.join
    self
  end
end
