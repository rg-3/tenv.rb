module TWEnv::Command::TweetFilter
  def read_and_filter(reader, filter, max_id)
    tweets = reader.call
    filtered = filter.call(tweets)
    if tweets.empty? || max_id == tweets[-1].id
      []
    elsif filtered.empty?
      read_and_filter(reader, filter, tweets[-1].id)
    else
      filtered
    end
  end

  def is_reply_to_filter!(tweets)
    tweets.select! do |tweet|
      next unless tweet.reply?
      user = client.user(tweet.in_reply_to_user_id)
      user.screen_name == opts['is-reply-to']
    rescue Twitter::Error::NotFound, Twitter::Error::Forbidden
      nil
    end if opts['is-reply-to']
  end
end
