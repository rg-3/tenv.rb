class Tenv
  require 'pry'
  require 'twitter'
  require 'tempfile'
  require_relative 'tenv/dot_env'
  require_relative 'tenv/command'
  require_relative 'tenv/write_tweet'
  require_relative 'tenv/random_tweet'

  def self.start_repl
    glob = File.join __dir__, '..', 'commands', '*.rb'
    Dir[glob].each {|path| require_command(path)}
    Pry.start new, extra_sticky_locals: {
      client: Twitter::REST::Client.new { |config|
        config.consumer_key        = ENV['TENV_CONSUMER_KEY']
        config.consumer_secret     = ENV['TENV_CONSUMER_KEY_SECRET']
        config.access_token        = ENV['TENV_ACCESS_TOKEN']
        config.access_token_secret = ENV['TENV_ACCESS_TOKEN_SECRET']
      }
    }
  end

  def self.require_command(path)
    require path
  rescue
    warn "#{path} couldn't be loaded"
  end
  private_class_method :require_command

  def initialize
    path = File.join(__dir__, '..', '.env')
    vars = DotEnv.read_dot_file(path)
    DotEnv.set_env(vars)
  end
end
