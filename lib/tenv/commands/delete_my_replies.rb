class Tenv::DeleteMyReplies < Tenv::Command
  match "delete-my-replies"
  description "Delete your replies"
  def process
    perform_action_on_tweets method(:get_tweets),
                             lambda {|tweet| client.destroy_tweet(tweet)},
                             lambda {|total| clear_line; print total == 0 ? "You have no replies to delete" : "#{total} replies deleted" }
  end

  private
  def get_tweets
    tweets = @last_id ? client.user_timeline(client.user, max_id: @last_id) : client.user_timeline(client.user)
    @last_id = tweets[-1]&.id
    tweets.size > 0 && tweets.select(&:reply?).empty? ? get_tweets : tweets
  end
end
