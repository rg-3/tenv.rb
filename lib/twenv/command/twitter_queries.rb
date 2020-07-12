module TWEnv::Command::TwitterQueries
  #
  # @param [String] user
  #   A twitter username.
  #
  # @params [Hash] options
  #   A Hash of options forwarded to `Twitter::REST::Client#user_timeline`.
  #
  # @return [Array<Tweet>]
  #   Returns an array of tweets from the timeline of *user*.
  #
  def user_timeline(user, options = {})
    options.delete(:max_id) unless options[:max_id]
    client.user_timeline(user, options)
  end
end
