class TWEnv::Command < Pry::ClassCommand
  require 'word_wrap'
  require 'fileutils'
  Dir.glob(File.join(__dir__, 'command', '*.rb')) { |f| require_relative(f) }

  include PerformActionOnTweets

  def self.add_command(command)
    Pry.commands.add_command command
  end

  def word_wrap(str, cols: 80, fit: true)
    WordWrap.ww str, cols, fit
  end

  def setup
    FileUtils.mkdir_p command_storage_path
  end

  #
  # @return [String]
  #  Returns the path to a directory where a command can store files.
  #
  def command_storage_path
    default = File.expand_path(File.join(__dir__, '..', '..', 'command_storage'))
    File.join ENV.fetch('TWENV_COMMAND_STORAGE_PATH', default), self.class.command_name
  end

  def client
    pry_instance.config.extra_sticky_locals[:client]
  end

  def user_timeline(user, options)
    options.delete(:max_id) unless options[:max_id]
    client.user_timeline(user, options)
  end

  def line
    @line ||= TWEnv::Line.new(pry_instance.output)
  end
end
