class TWEnv::ArchiveTimeline < TWEnv::Command
  match 'archive-timeline'
  description 'Archive a timeline of tweets'
  command_options argument_required: true, setup_storage: true
  group 'twenv'
  banner <<-BANNER
  archive-timeline [options] USER

  #{description}
  BANNER

  attr_accessor :max_id
  include TWEnv::Command::Archiveable

  def setup
    super
    @user = nil
    @path = nil
  end

  def process(user)
    @user = user
    @path = File.join command_storage_path, "#{user}.json"
    write_file @path, [], 'json'
    perform_action_on_tweets method(:read_tweets),
                             method(:archive_tweet),
                             method(:print_total)
  rescue Interrupt
    line.end_line
  ensure
    puts "Archive saved to #{@path}"
  end

  def options(slop)
    share_archive_options slop, "tweets"
    slop.on :'no-retweets', "Only archive tweets that aren't retweets", default: false, as: :boolean
    slop.on :'retweets-only', "Only archive tweets that are retweets", default: false, as: :boolean
    slop.on :'replies-only', "Only archive tweets that are replies", default: false, as: :boolean
    slop.on :'no-replies', "Only archive tweets that aren't replies", default: false, as: :boolean
    slop.on :'video-only', "Only archive tweets that include video", default: false, as: :boolean
    slop.on :'no-video', "Only archive tweets that don't include video", default: false, as: :boolean
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
    line.rewind.print "#{total} tweets archived"
    throw(:cancel) if opts[:max].nonzero? && total == opts[:max]
  end

  def archive_tweet(tweet)
    tweets = parse_file @path, 'json'
    tweets.push format_tweet(tweet)
    write_file @path, tweets, 'json'
  end

  def filter_tweets(tweets)
    tweets = filter_archive_tweets(tweets)
    tweets.reject!(&:retweet?) if opts['no-retweets']
    tweets.select!(&:retweet?) if opts['retweets-only']
    tweets.select!(&:reply?) if opts['replies-only']
    tweets.reject!(&:reply?) if opts['no-replies']
    tweets.select!{|t| t.media.any?{|m| m.instance_of?(Twitter::Media::Video) } } if opts['video-only']
    tweets.reject!{|t| t.media.any?{|m| m.instance_of?(Twitter::Media::Video) } } if opts['no-video']
    tweets
  end

  add_command self
end
