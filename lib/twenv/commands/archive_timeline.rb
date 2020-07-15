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

  attr_accessor :max_id

  def setup
    super
    @user = nil
    @path = nil
  end

  def process(user)
    @user = user
    @path = File.join command_storage_path, "#{user}.#{opts[:format].downcase}"
    write_file @path, [], opts[:format]
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
    slop.on :'replies-only', "Only archive tweets that are replies", default: false, as: :boolean
    slop.on :'no-replies', "Only archive tweets that aren't replies", default: false, as: :boolean
  end

  private

  def read_tweets
    read_and_filter method(:tweet_reader),
                    method(:filter_tweets),
                    max_id
  end

  def tweet_reader
    tweets = user_timeline(@user, tweet_mode: 'extended', max_id: max_id)
    tweets.tap { self.max_id = tweets[-1]&.id }
  end

  def print_total(total)
    line.empty_line!.print "#{total} tweets archived"
    throw(:cancel) if total == opts[:max]
  end

  def archive_tweet(tweet)
    tweets = parse_file @path, opts[:format]
    tweets.push format_tweet(tweet)
    write_file @path, tweets, opts[:format]
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
    tweets.select!(&:reply?) if opts['replies-only']
    tweets.reject!(&:reply?) if opts['no-replies']
    tweets
  end

  add_command self
end
