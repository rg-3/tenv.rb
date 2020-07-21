class TWEnv::DeleteMyTweets < TWEnv::Command
  match "delete-my-tweets"
  description "Delete tweets made by `client.user`"
  group 'twenv'
  banner <<-BANNER
  delete-my-tweets [OPTIONS]

  #{description}
  BANNER

  attr_accessor :max_id

  def options(slop)
    slop.on 'has-no-likes' , "Only delete tweets with no likes", as: :boolean, default: false
    slop.on 'is-reply'     , "Only delete tweets that are replies", as: :boolean, default: false
  end

  def process
    perform_action_on_tweets method(:read_tweets),
                             lambda {|tweet| client.destroy_tweet(tweet)},
                             lambda {|total| line.rewind.print(total == 0 ? "No tweets to delete" : "#{total} tweets deleted") }
  end

  private

  def read_tweets
    read_and_filter method(:tweet_reader),
                    method(:filter_tweets),
                    max_id
  end

  def tweet_reader
    tweets = user_timeline(client.user, max_id: max_id)
    tweets.tap { self.max_id = tweets[-1]&.id }
  end

  def filter_tweets(tweets)
    tweets = tweets.dup
    tweets.select!(&:reply?) if opts['is-reply']
    tweets.select! {|tweet| tweet.favorite_count.zero?} if opts['has-no-likes']
    tweets
  end

  add_command self
end
