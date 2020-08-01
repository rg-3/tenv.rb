module TWEnv::Command::TwitterActions
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

  def home_timeline(options = {})
    options.delete(:max_id) unless options[:max_id]
    client.home_timeline(options)
  end

  #
  # @param [String] user
  #   A twitter username.
  #
  # @params [Hash] options
  #   A Hash of options forwarded to `Twitter::REST::Client#favorites`.
  #
  # @return [Array<Tweet>]
  #   Returns an array of tweets liked by *user*.
  #
  def user_likes(user, options = {})
    options.delete(:max_id) unless options[:max_id]
    client.favorites(user, options)
  end
end
