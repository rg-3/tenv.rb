class TwEnv
  require 'pry'
  require 'twitter'
  require 'tempfile'
  require_relative 'twenv/command'
  require_relative 'twenv/write_tweet'

  def self.start_repl
    Pry.start new, extra_sticky_locals: {
      client: Twitter::REST::Client.new { |config|
        config.consumer_key        = ENV['TWENV_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWENV_CONSUMER_KEY_SECRET']
        config.access_token        = ENV['TWENV_ACCESS_TOKEN']
        config.access_token_secret = ENV['TWENV_ACCESS_TOKEN_SECRET']
      }
    }
  end

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
