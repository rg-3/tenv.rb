class TWEnv
  require 'pry'
  require 'twitter'
  require 'tempfile'
  require_relative 'twenv/dot_env'
  require_relative 'twenv/command'
  require_relative 'twenv/line'
  require_relative 'twenv/version'
  require_relative 'twenv/struct'
  Dir[File.join(__dir__, "twenv", "commands", "*.rb")].each{|file| require_relative file}

  def self.start(twitter_options = {}, pry_options = {})
    glob = File.join __dir__, '..', 'commands', '*.rb'
    Dir[glob].each {|path| require_command(path)}
    Pry.start new, {
      extra_sticky_locals: {
        client: Twitter::REST::Client.new { |config|
          config.consumer_key        = ENV['TWENV_CONSUMER_KEY']
          config.consumer_secret     = ENV['TWENV_CONSUMER_KEY_SECRET']
          config.access_token        = ENV['TWENV_ACCESS_TOKEN']
          config.access_token_secret = ENV['TWENV_ACCESS_TOKEN_SECRET']
          twitter_options.each {|k,v| config.send("#{k}=", v)}
        }
      }
    }.merge!(pry_options)
  end

  #
  # @return [String]
  #   The path to the root of the twenv.rb repository
  #
  def self.root_path
    @root_path ||= File.expand_path File.join(__dir__, "..")
  end

  def self.require_command(path)
    require path
  rescue
    warn "Error while loading #{path}"
  end
  private_class_method :require_command

  def initialize
    path = File.join(__dir__, '..', '.env')
    vars = DotEnv.read_dot_file(path)
    DotEnv.set_env(vars)
  end
end
