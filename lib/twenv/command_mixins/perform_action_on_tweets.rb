module TWEnv::Command::PerformActionOnTweets
  #
  # Performs an action on a set of tweets until there are no tweets left to
  # be read.
  #
  # @param [Proc, #call] read_tweets
  #   A Proc that returns an array of tweets.
  #
  # @param [Proc, #call] perform_action
  #   A Proc that receives a tweet and performs an action on it.
  #
  # @param [Proc, #call]
  #   A Proc that receives the count of tweets read so far.
  #
  # @return [void]
  #
  def perform_action_on_tweets(read_tweets, perform_action, total_recver, ids = [])
    catch(:cancel) do
      tweets = read_tweets.call
      if tweets.empty?
        total_recver.call(ids.size)
        throw(:cancel)
      end
      until tweets.empty?
        tweets.each do |tweet|
          next if ids.include?(tweet.id)
          ids.push(tweet.id)
          perform_action.call(tweet)
          total_recver.call(ids.size)
        end
        tweets = read_tweets.call
      end
    end
    line.end_line
  rescue Twitter::Error::TooManyRequests => e
    rate_limit_sleep(e.rate_limit.retry_after)
    perform_action_on_tweets(read_tweets, perform_action, total_recver, ids)
  end

  private

  def rate_limit_sleep(seconds)
    line.empty_line!.print "Rate limited by Twitter for #{seconds} seconds. "
    sleep 1
    seconds -= 1
    seconds > 0 ? rate_limit_sleep(seconds) : line.empty_line!
  end
end