module TWEnv::Command::FormatTweet
  #
  # @param [Twitter::Tweet] tweet
  #   A tweet object.
  #
  # @return [Hash]
  #   Returns a representation of a tweet as a Hash.
  #
  def format_tweet(tweet)
    user = tweet.attrs[:user]
    {
      id: tweet.id,
      url: tweet.url.to_s,
      text: tweet.full_text,
      is_retweet: tweet.retweet?,
      retweet_count: tweet.retweet_count,
      like_count: tweet.favorite_count,
      created_at: tweet.created_at.iso8601,
      archived_at: Time.now.utc.iso8601,
      urls: tweet.urls.map{|u| u.attrs.slice(:url, :expanded_url, :display_url)},
      user_mentions: tweet.user_mentions.map{|u| u.attrs.slice(:id, :screen_name, :name) },
      author: user.slice(
        :id,
        :name,
        :screen_name,
        :location,
        :description,
        :verified,
        :protected,
        :followers_count,
        :listed_count
      ).merge!(tweet_count: user[:statuses_count], like_count: user[:favourites_count])
    }
  end
end
