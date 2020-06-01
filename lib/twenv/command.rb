class TwEnv::Command < Pry::ClassCommand
  def twitter_client
    _pry_.config.extra_sticky_locals[:client]
  end
end
