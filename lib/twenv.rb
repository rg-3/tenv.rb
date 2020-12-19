class TWEnv
  require 'pry'
  require 'twitter'
  require 'tempfile'
  require 'paint'
  require_relative 'twenv/pry/class_command'
  require_relative 'twenv/command'
  require_relative 'twenv/line'
  require_relative 'twenv/version'
  require_relative 'twenv/struct'
  require_relative 'twenv/error'
  Dir[File.join(__dir__, "twenv", "commands", "*.rb")].each{|file| require_relative file}

  def self.start(twitter_options = {}, pry_options = {})
    glob = File.join __dir__, '..', 'scripts', '*.rb'
    Dir[glob].each {|path| require_script(path)}
    ENV.update parse_dot_file(dot_env_path)
    Pry.start TOPLEVEL_BINDING, {
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

  #
  # @return [String]
  #   Returns the path to the `.env` file.
  #
  def self.dot_env_path
    File.join TWEnv.root_path, '.env'
  end

  private_class_method def self.parse_dot_file(path)
    return {} unless File.exist? path
    Hash[
      File.read(path).each_line.map do |line|
        next unless line =~ /^[\w]+=[\w]+/
        line.strip.split(/=/, 2)
      end.compact
    ]
  end

  private_class_method def self.require_script(path)
    require(path)
  rescue => ex
    warn "The script '#{path}' could not be loaded (#{ex.class})"
  end
end

Pry.configure do |config|
  config.prompt_name = "twenv.rb "
end
