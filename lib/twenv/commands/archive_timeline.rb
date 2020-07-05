class TWEnv::ArchiveTimeline < TWEnv::Command
  require 'json'
  require 'yaml'

  match 'archive-timeline'
  description 'Archive a timeline of tweets'
  command_options argument_required: true
  group 'twenv'
  banner <<-BANNER
  archive-timeline [options] USER

  #{description}
  BANNER

  def setup
    @user = nil
    @path = nil
    @max_id = nil
  end

  def process(user)
    @user = user
    @path = File.join command_storage_path, "#{user}.#{opts[:format].downcase}"
    write_file @path, []
    perform_action_on_tweets method(:read_tweets),
                             method(:archive_tweet),
                             method(:print_total)
    puts "Archive saved to #{@path}"
  end

  def options(slop)
    slop.on :m, :max=, 'The maximum number of tweets to archive. Default is 50', default: 50, as: :integer
    slop.on :f, :format=, 'The format to store the timeline in (eg json, yaml). Default is json', default: 'json', as: :string
    slop.on :'outbound-links-only', 'Only archive tweets that link to somewhere outside Twitter', default: false, as: :boolean
    slop.on :'no-media', "Only archive tweets that don't include media (eg video, images)", default: false
    slop.on :'media-only', "Only archive tweets that do include media (eg video, images)", default: false
    slop.on :'no-links', "Only archive tweets that don't include links", default: false, as: :boolean
    slop.on :'links-only', "Only archive tweets that do include links", default: false, as: :boolean
    slop.on :'no-retweets', "Only archive tweets that aren't retweets", default: false, as: :boolean
    slop.on :'retweets-only', "Only archive tweets that are retweets", default: false, as: :boolean
  end

  private

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

  def print_total(total)
    line.print "#{total} tweets archived"
    throw(:cancel) if total == opts[:max]
  end

  def archive_tweet(tweet)
    tweets = parse_file(@path)
    tweets.push format_tweet(tweet)
    write_file @path, tweets
  end

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

  def filter_tweets(tweets)
    tweets = tweets.dup
    tweets.select! {|t| t.urls.any? { |url| url.expanded_url.host != 'twitter.com' } } if opts['outbound-links-only']
    tweets.select! {|t| t.media.empty?} if opts['no-media']
    tweets.select! {|t| t.media.size > 0} if opts['media-only']
    tweets.select! {|t| t.urls.empty? } if opts['no-links']
    tweets.select! {|t| t.urls.size >0} if opts['links-only']
    tweets.reject!(&:retweet?) if opts['no-retweets']
    tweets.select!(&:retweet?) if opts['retweets-only']
    tweets
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
