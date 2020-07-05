class TWEnv::ArchiveTimeline < TWEnv::Command
  require 'json'
  require 'yaml'

  match 'archive-timeline'
  description 'Archive a timeline of tweets'
  command_options argument_required: true
  group 'twenv'
  banner <<-BANNER
  archive-timeline [options] USER

  Archive a timeline of tweets
  BANNER

  def setup
    @user = nil
    @path = nil
    @max_id = nil
  end

  def process(user)
    @user = user
    @path = File.join(TWEnv.data_dir, "#{user}.#{opts[:format].downcase}")
    write_file @path, []
    perform_action_on_tweets method(:read_tweets),
                             method(:archive_tweet),
                             method(:print_total)
    puts "Archive saved to #{@path}"
  end

  def options(slop)
    slop.on :m, :max=, 'The maximum number of tweets to archive. Default is 500', default: 500, argument_required: true, as: :integer
    slop.on :f, :format=, 'The format to store the timeline in (eg json, yaml). Default is json', default: 'json', argument_required: true, as: :string
    slop.on :'outbound-links-only', 'Only archive tweets that link to somewhere outside Twitter', default: false, as: :boolean
  end

  private

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

  def read_tweets
    tweets = user_timeline(@user, tweet_mode: 'extended', max_id: @max_id)
    filtered = filter_tweets(tweets)
    if tweets.empty? || @max_id == tweets[-1].id
      []
    elsif filtered.empty?
      @max_id = tweets[-1].id
      read_tweets
    else
      @max_id = tweets[-1].id
      filtered
    end
  end

  def filter_tweets(tweets)
    tweets = tweets.dup
    tweets.select! do |t|
      t.urls.any? { |url| url.expanded_url.host != 'twitter.com' }
    end if opts['outbound-links-only']
    tweets
  end

  def print_total(total)
    line.print "#{total} tweets archived"
    throw(:cancel) if total == opts[:max]
  end

  def archive_tweet(tweet)
    tweets = parse_file(@path)
    tweets.push format_tweet(tweet)
    write_file @path, tweets
  end

  def parse_file(path)
    case opts[:format]
    when /json/i then JSON.parse File.read(path)
    when /yaml/i then YAML.load File.read(path)
    end
  end

  def write_file(path, tweets)
    case opts[:format]
    when /json/i then File.write path, JSON.dump(tweets)
    when /yaml/i then File.write path, YAML.dump(tweets)
    end
  end

  add_command self
end
