class TWEnv::DeleteMyLikes < TWEnv::Command
  match 'delete-my-likes'
  description 'Delete my likes'

  def process
    perform_action_on_tweets lambda { client.favorites },
                             lambda {|tweet| client.unfavorite(tweet) },
                             lambda {|total| clear_line; print total == 0 ? "You have no tweets to unlike" : "#{total} tweets unliked" }
  end
end
