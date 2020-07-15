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
end
