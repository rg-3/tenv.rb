class Tenv::Command < Pry::ClassCommand
  def self.inherited(klass)
    Thread.new do
      # After 0.5 seconds a command ought to have called 'match',
      # but this obviously sucks :) 
      sleep 0.5
      Pry.commands.add_command(klass)
    end
  end

  def twitter_client
    pry_instance.config.extra_sticky_locals[:client]
  end
end
