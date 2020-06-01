require 'pry'
require 'twitter'

class TwEnv
  def self.start_repl
    Pry.start new
  end

  def initialize
    prepare_env
  end

  private

  def client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWENV_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWENV_CONSUMER_KEY_SECRET']
      config.access_token        = ENV['TWENV_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWENV_ACCESS_TOKEN_SECRET']
    end
  end

  def prepare_env
    env_path = File.join(__dir__, '..', '.env')
    if File.exist? env_path
      File.read(env_path).each_line do |line|
        next unless line =~ /^[\w]+=[\w]+/
        key, value = line.split(/=/, 2)
        ENV[key] = value.strip
      end
    end
  end
end
