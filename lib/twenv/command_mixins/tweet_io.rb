module TWEnv::Command::TweetIO
  require 'json'

  class Tweet < OpenStruct
    def to_json(options = {})
      @table.to_json(options)
    end
  end

  def read_tweets_array(path)
    tweets = JSON.parse File.read(path)
    tweets.map {|tweet| Tweet.new(tweet)}
  end

  def write_tweets_array(path, tweets)
    File.write path, JSON.dump(tweets)
  end
end
