class TWEnv::Command < Pry::ClassCommand
  require 'fileutils'
  Dir.glob(File.join(__dir__, 'command_mixins', '*.rb')) { |f| require_relative(f) }

  include PerformActionOnTweets
  include TwitterActions
  include FormatTweet
  include TweetFilter
  include TweetIO

  def self.add_command(command)
    Pry.commands.add_command command
  end

  def setup
    command_options = self.class.command_options
    FileUtils.mkdir_p(storage_path) if command_options[:storage]
  end

  #
  # @return [Hash]
  #  Returns a Hash of local variables that persist throughout the repl
  #  session. Mutation of the Hash adds or removes local variables from
  #  the repl session.
  #
  def sticky_locals
    pry_instance.config.extra_sticky_locals
  end

  #
  # @return [String]
  #  Returns the path to a directory where a command can store files.
  #
  def storage_path
    default = File.expand_path(File.join(__dir__, '..', '..', 'storage'))
    File.join ENV.fetch('TWENV_COMMAND_STORAGE_PATH', default), self.class.command_name
  end

  #
  # @return [Twitter::REST::Client]
  #  Returns a configured instance of Twitter::REST::Client.
  #
  def client
    pry_instance.config.extra_sticky_locals[:client]
  end

  #
  # @return [TWEnv::Line]
  #  Returns an instance of {TWEnv::Line}, a reusable line of output.
  #
  def line
    @line ||= TWEnv::Line.new(pry_instance.output)
  end
end
