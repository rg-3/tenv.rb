class TWEnv::DeleteMyReplies < TWEnv::Command
  match "delete-my-replies"
  description "Delete your replies"

  def setup
    @max_id = nil
  end

  def process
    perform_action_on_tweets method(:read_tweets),
                             lambda {|tweet| client.destroy_tweet(tweet)},
                             lambda {|_, total| clear_line; print total == 0 ? "You have no replies to delete" : "#{total} replies deleted" }
  end

  private
  def read_tweets
    tweets  = user_timeline(client.user, @max_id)
    replies = tweets.select(&:reply?)
    if tweets.empty? || @max_id == tweets[-1]&.id
      []
    elsif replies.empty?
      @max_id = tweets[-1].id
      read_tweets
    else
      @max_id = tweets[-1].id
      replies
    end
  end
end
