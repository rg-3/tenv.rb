class Tenv::Command < Pry::ClassCommand
  require 'word_wrap'
  BACKSPACE_CHAR = "\010"

  def self.inherited(klass)
    Thread.new do
      # After 0.5 seconds a command ought to have called 'match',
      # but this obviously sucks :)
      sleep 0.5
      klass.group 'tenv'
      Pry.commands.add_command(klass)
    end
  end

  def word_wrap(str, cols: 80, fit: true)
    WordWrap.ww str, cols, fit
  end

  def clear_line(width = 1024)
    print BACKSPACE_CHAR*width
  end

  def client
    pry_instance.config.extra_sticky_locals[:client]
  end
end
