require 'word_wrap'
class Tenv::Command < Pry::ClassCommand
  group 'tenv'

  def self.inherited(klass)
    Thread.new do
      # After 0.5 seconds a command ought to have called 'match',
      # but this obviously sucks :)
      sleep 0.5
      Pry.commands.add_command(klass)
    end
  end

  def word_wrap(str, cols: 80, fit: true)
    WordWrap.ww str, cols, fit
  end

  def twitter_client
    pry_instance.config.extra_sticky_locals[:client]
  end
end
