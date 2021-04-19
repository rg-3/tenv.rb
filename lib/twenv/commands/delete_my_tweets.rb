class TWEnv::DeleteMyTweets < TWEnv::Command
  match "delete-my-tweets"
  description "Delete tweets made by `client.user`"
  group "twenv"
  banner <<-BANNER
  delete-my-tweets [OPTIONS]

  #{description}

  # Delete tweets who were published before 24th, Dec, 2020
  delete-my-tweets --before-date 24/12/2020
  BANNER

  attr_accessor :max_id

  def options(slop)
    slop.on "has-likes", "Only delete tweets with likes", as: :boolean, default: false
    slop.on "has-no-likes", "Only delete tweets with no likes", as: :boolean, default: false
    slop.on "is-not-reply", "Only delete tweets that aren't replies", as: :boolean, default: false
    slop.on "is-reply", "Only delete tweets that are replies", as: :boolean, default: false
    slop.on "is-reply-to=", "Only delete tweets that are a reply to the given username", as: :string, default: nil
    slop.on "has-media", "Only delete tweets that have media (either video or image)", default: false
    slop.on "no-media", "Only delete tweets that don't have media (either video or image)", default: false
    slop.on "before-date=", "Only delete tweets that were published before the given date (iso8601 format)", default: nil, as: :string
    slop.on "has-outbound-links", "Only delete tweets that link to somewhere outside Twitter", default: false, as: :boolean
  end

  def process
    perform_action_on_tweets method(:read_tweets), method(:destroy_tweet), method(:print_total)
    line.end
  rescue Interrupt
    line.end
    line.warn("Interrupt received").end
  end

  private

  def read_tweets
    read_and_filter method(:tweet_reader), method(:filter_tweets), max_id
  end

  def tweet_reader
    tweets = user_timeline(client.user, max_id: max_id)
    tweets.tap { self.max_id = tweets[-1]&.id }
  end

  def filter_tweets(tweets)
    tweets = tweets.dup
    tweets.select!(&:reply?) if opts["is-reply"] || opts["is-reply-to"]
    tweets.reject!(&:reply?) if opts["is-not-reply"]
    tweets.select! { |tweet| tweet.favorite_count.zero? } if opts["has-no-likes"]
    tweets.select! { |tweet| tweet.favorite_count > 0 } if opts["has-likes"]
    tweets.select! { |t| t.media.empty? } if opts["no-media"]
    tweets.select! { |t| t.media.size > 0 } if opts["has-media"]
    tweets.select! { |t| t.urls.any? { |url| url.expanded_url.host != "twitter.com" } } if opts["has-outbound-links"]
    tweets.reject! { |t| t.created_at >= Time.strptime(opts["before-date"], "%Y-%m-%d") } if opts["before-date"]
    is_reply_to_filter!(tweets, opts["is-reply-to"])
    tweets
  end

  def destroy_tweet(tweet)
    client.destroy_tweet(tweet)
  end

  def print_total(total)
    line.rewind.ok("#{total} tweets deleted")
  end

  add_command self
end
