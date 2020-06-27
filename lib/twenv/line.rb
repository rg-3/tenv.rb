class TWEnv::Line
  BACKSPACE = "\010"

  def initialize(io)
    @io = io
    @buffer_size = 0
  end

  def print(str)
    clear_line
    str.gsub!("\n", "")
    @buffer_size = str.size
    @io.print str
  end

  def end_line
    @io.print "\n"
  end

  private

  def clear_line
    @io.print BACKSPACE * @buffer_size
  end
end
