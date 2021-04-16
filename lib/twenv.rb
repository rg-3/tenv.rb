class TWEnv
  require 'pry'
  require 'twitter'
  require 'twitter-text'
  require 'tempfile'
  require 'paint'
  require_relative 'twenv/pry/class_command'
  require_relative 'twenv/command'
  require_relative 'twenv/line'
  require_relative 'twenv/version'
  require_relative 'twenv/struct'
  require_relative 'twenv/error'
  require_relative 'twitter/rest/client'
  Dir[File.join(__dir__, "twenv", "commands", "*.rb")].each{|file| require_relative file}

  def self.start(pry_options = {})
    init_files.each {|file| require_script(file) }
    ENV.update parse_dot_file(dot_env_path)
    Pry.start(TOPLEVEL_BINDING, default_pry_options.merge!(pry_options))
  end

  #
  # @return [String]
  #  The path to the root of the twenv.rb repository
  #
  def self.root_path
    @root_path ||= File.expand_path File.join(__dir__, "..")
  end

  #
  # @return [String]
  #  Returns the path to the `.env` file.
  #
  def self.dot_env_path
    File.join root_path, '.env'
  end

  #
  # @return [String]
  #  Returns the default value for the user-agent header.
  #
  def self.user_agent
    "twenv.rb v#{TWEnv::VERSION}"
  end

  #
  # @return [Array<String>]
  #  Returns an array of paths that will be automatically
  #  loaded when twenv.rb starts.
  #
  def self.init_files
    glob = File.join root_path, 'scripts', '*_*.rb'
    init_files = Dir[glob].select {|path| File.basename(path).match?(/^\d+_/) }
    init_files.sort_by! do |path|
      basename = File.basename(path)
      basename[/\d+/]
    end
  end

  def self.default_pry_options
    {extra_sticky_locals: {client: new_client}}
  end
  private_class_method :default_pry_options

  def self.new_client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWENV_CONSUMER_KEY']
      config.consumer_secret     = ENV['TWENV_CONSUMER_KEY_SECRET']
      config.access_token        = ENV['TWENV_ACCESS_TOKEN']
      config.access_token_secret = ENV['TWENV_ACCESS_TOKEN_SECRET']
      config.user_agent = user_agent
    end
  end
  private_class_method :new_client

  def self.parse_dot_file(path)
    return {} unless File.exist? path
    Hash[
      File.read(path).each_line.map do |line|
        next unless line =~ /^[\w]+=[\w]+/
        line.strip.split(/=/, 2)
      end.compact
    ]
  end
  private_class_method :parse_dot_file

  def self.require_script(path)
    require(path)
  rescue => ex
    warn "The script '#{path}' could not be loaded (#{ex.class})"
  end
  private_class_method :require_script
end

Pry.configure do |config|
  config.prompt_name = config.color ? Paint["twenv.rb ", :green, :bold] : "twenv.rb "
end
