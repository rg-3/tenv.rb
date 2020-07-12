class TWEnv::Line
  BACKSPACE = "\010"

  def initialize(io)
    @io = io
    @size = 0
  end

  def print(str)
    str = remove_newlines(str)
    @size = str.size
    @io.print str
    self
  end

  def end_line
    @io.print "\n"
    self
  end

  def empty_line!
    @io.print BACKSPACE * @size
    self
  end

  private

  def remove_newlines(str)
    str.gsub(/[\n]*/, '')
  end
end
