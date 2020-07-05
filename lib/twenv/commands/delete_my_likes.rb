class TWEnv::DeleteMyLikes < TWEnv::Command
  match 'delete-my-likes'
  description 'Delete tweets liked by `client.user`'
  group 'twenv'

  def process
    perform_action_on_tweets lambda { client.favorites },
                             lambda {|tweet| client.unfavorite(tweet) },
                             lambda {|total| line.print(total == 0 ? "No tweets to unlike" : "#{total} tweets unliked") }
  end

  add_command self
end
