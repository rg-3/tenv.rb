class TWEnv::DeleteMyTweets < TWEnv::Command
  match "delete-my-tweets"
  description "Delete tweets made by `client.user`"
  group 'twenv'
  banner <<-BANNER
  delete-my-tweets [OPTIONS]

  #{description}
  BANNER

  def setup
    super
    @max_id = nil
  end

  def options(slop)
    slop.on :'with-no-likes', "Only delete tweets with no likes", as: :boolean, default: false
    slop.on :'replies-only' , "Only delete tweets that are replies", as: :boolean, default: false
  end

  def process
    perform_action_on_tweets method(:read_tweets),
                             lambda {|tweet| client.destroy_tweet(tweet)},
                             lambda {|total| line.print(total == 0 ? "No tweets to delete" : "#{total} tweets deleted") }
  end

  private
  def read_tweets
    tweets = user_timeline(client.user, max_id: @max_id)
    filtered = filter_tweets(tweets)
    if tweets.empty? || @max_id == tweets[-1].id
      []
    elsif filtered.empty?
      @max_id = tweets[-1].id
      read_tweets
    else
      @max_id = tweets[-1].id
      filtered
    end
  end

  def filter_tweets(tweets)
    tweets = tweets.dup
    tweets.select!(&:reply?) if opts['replies-only']
    tweets.select! {|tweet| tweet.favorite_count.zero?} if opts['with-no-likes']
    tweets
  end

  add_command self
end
