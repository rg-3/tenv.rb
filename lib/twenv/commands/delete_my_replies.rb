class TWEnv::DeleteMyReplies < TWEnv::Command
  match "delete-my-replies"
  description "Delete replies made by `client.user`"
  group 'twenv'
  banner <<-BANNER
  delete-my-replies [OPTIONS]

  #{description}
  BANNER

  def setup
    @max_id = nil
  end

  def options(slop)
    slop.on :'with-no-likes', "Don't delete tweets with at least one like", as: :boolean, default: false
  end

  def process
    perform_action_on_tweets method(:read_tweets),
                             lambda {|tweet| client.destroy_tweet(tweet)},
                             lambda {|total| line.print(total == 0 ? "You have no replies to delete" : "#{total} replies deleted") }
  end

  private
  def read_tweets
    tweets  = user_timeline(client.user, max_id: @max_id)
    replies = filter_tweets(tweets)
    if tweets.empty? || @max_id == tweets[-1].id
      []
    elsif replies.empty?
      @max_id = tweets[-1].id
      read_tweets
    else
      @max_id = tweets[-1].id
      replies
    end
  end

  def filter_tweets(tweets)
    tweets = tweets.select(&:reply?)
    if opts['with-no-likes']
      tweets.reject! {|tweet| tweet.favorite_count > 0}
    end
    tweets
  end

  add_command self
end
