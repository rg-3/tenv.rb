class TWEnv::WriteTweet < TWEnv::Command
  match 'write-tweet'
  description "Write a tweet"
  group 'twenv'

  def process
    raise Pry::CommandError, "$EDITOR is not set" if empty?(ENV['EDITOR'])
    file = Tempfile.new('twenv')
    system ENV['EDITOR'], file.path
    tweet = file.read
    raise Pry::CommandError, "tweet content is empty" if empty?(tweet)
    client.update(tweet)
  ensure
    file.unlink
    file.close
  end

  private

  def empty?(o)
    o.nil? || o.strip.empty?
  end

  add_command self
end
