class TWEnv::WriteTweet < TWEnv::Command
  match 'write-tweet'
  description "Write a tweet on behalf of `client.user`"
  group 'twenv'
  command_options storage: true
  banner <<-BANNER
  write-tweet [OPTIONS]

  #{description}
  BANNER

  def options(slop)
    slop.on :d, :delay=, 'Delay sending a tweet by a number of seconds', as: :integer, default: 0
  end

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
    time = Time.now + delay
    line.ok("tweet will be published at around #{bold(format_time(time, :upcase))}. " \
            "If this twenv.rb process exits before then the tweet won't be published.").end
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
