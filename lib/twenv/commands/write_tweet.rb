class TWEnv::WriteTweet < TWEnv::Command
  match 'write-tweet'
  description "Write a tweet"
  group 'twenv'

  def process
    unless ENV['EDITOR']
      raise Pry::CommandError, "Aborting because $EDITOR was not set."
    end
    file = Tempfile.new('twenv')
    system ENV['EDITOR'], file.path
    client.update(file.read)
  ensure
    file.unlink
    file.close
  end

  add_command self
end
