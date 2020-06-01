class Tenv
  require 'pry'
  require 'twitter'
  require 'tempfile'
  require_relative 'tenv/command'
  require_relative 'tenv/write_tweet'

  def self.start_repl
    glob = File.join __dir__, '..', 'commands', '*.rb'
    Dir[glob].each {|path| require_command(path)}
    Pry.start new, extra_sticky_locals: {
      client: Twitter::REST::Client.new { |config|
        config.consumer_key        = ENV['TWENV_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWENV_CONSUMER_KEY_SECRET']
        config.access_token        = ENV['TWENV_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWENV_ACCESS_TOKEN_SECRET']
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
    read_env_dotfile
  end

  private
  def read_env_dotfile
    env_path = File.join(__dir__, '..', '.env')
    return unless File.exist? env_path
    File.read(env_path).each_line do |line|
      next unless line =~ /^[\w]+=[\w]+/
      key, value = line.split(/=/, 2)
      ENV[key] = value.strip
    end
  end
end
