class TWEnv::ArchiveLikes < TWEnv::Command
  match 'archive-likes'
  description 'Archive tweets a user has liked'
  command_options argument_required: true, setup_storage: true
  group 'twenv'
  banner <<-BANNER
  archive-likes [options] USER

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
    @path = File.join storage_path, "#{user}.json"
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
    share_archive_options slop, "likes"
  end

  private

  def read_tweets
    read_and_filter method(:tweet_reader),
                    method(:filter_tweets),
                    max_id
  end

  def tweet_reader
    tweets = user_likes(@user, tweet_mode: 'extended', max_id: max_id)
    tweets.tap { self.max_id = tweets[-1]&.id }
  end

  def print_total(total)
    line.rewind.print "#{total} likes archived"
    throw(:cancel) if opts[:max].nonzero? && total == opts[:max]
  end

  def archive_tweet(tweet)
    tweets = parse_file @path, 'json'
    tweets.push format_tweet(tweet)
    write_file @path, tweets, 'json'
  end

  def filter_tweets(tweets)
    filter_archive_tweets(tweets)
  end

  add_command self
end
