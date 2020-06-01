class TwEnv::Command < Pry::ClassCommand
  def self.inherited(klass)
    Pry.commands.add_command(klass)
  end

  def twitter_client
    pry_instance.config.extra_sticky_locals[:client]
  end
end
