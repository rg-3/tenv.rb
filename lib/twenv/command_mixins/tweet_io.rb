module TWEnv::Command::TweetIO
  require 'json'

  def read_tweets_array(path)
    tweets = JSON.parse File.read(path)
    tweets.map {|tweet| TWEnv::Struct.from_hash(tweet)}
  end

  def write_tweets_array(path, tweets)
    File.write path, JSON.dump(tweets)
  end
end
