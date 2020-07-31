class TWEnv::WriteTweet < TWEnv::Command
  match 'write-tweet'
  description "Write a tweet"
  group 'twenv'
  command_options storage: true

  def options(slop)
    slop.on :d, :delay=, 'Delay sending a tweet by X seconds', as: :integer, default: 0
  end

  def process
    raise Pry::CommandError, "set $EDITOR and try again" if empty?(ENV['EDITOR'])
    tweet = read_tweet
    delay.zero? ? post_tweet(tweet) : delay_tweet(tweet)
  end

  private

  def post_tweet(tweet, print_progress=true)
    line.print "Posting tweet ... " if print_progress
    client.update(tweet)
    line.print("Done.").end if print_progress
  end

  def delay_tweet(tweet)
    line.ok("tweet will be published in #{delay} seconds").end
    Thread.new do
      sleep delay
      post_tweet(tweet, false)
    end
  end

  def read_tweet
    file = Tempfile.new 'twenv', storage_path
    system ENV['EDITOR'], file.path
    tweet = file.read
    raise Pry::CommandError, "tweet content is empty" if empty?(tweet)
    tweet
  ensure
    file.unlink
    file.close
  end

  def delay
    opts[:delay]
  end

  def empty?(o)
    o.nil? || o.strip.empty?
  end

  add_command self
end
