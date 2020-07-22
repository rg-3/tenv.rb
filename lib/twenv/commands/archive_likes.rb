class TWEnv::ArchiveLikes < TWEnv::Command
  match 'archive-likes'
  description 'Archive tweets a user has liked'
  command_options argument_required: true, setup_storage: true
  group 'twenv'
  banner <<-BANNER
  archive-likes [options] USER

  #{description}
  BANNER

  attr_accessor :user, :path, :max_id

  include TWEnv::Command::ArchiveMixin

  def process(user)
    self.user = user
    self.path = File.join storage_path, "#{user}.json"
    opts['continue'] ? self.max_id = read_tweets_array(path).dig(-1, "id") : write_tweets_array(path, [])
    perform_action_on_tweets method(:read_tweets),
                             method(:archive_tweet),
                             method(:print_total),
                             read_tweets_array(path).map(&:id)
  rescue Interrupt
    line.end_line
  ensure
    sticky_locals.merge!(archived_likes: read_tweets_array(path))
    line.puts "Archive saved to #{path}"
    line.puts "Archive assigned to local variable `archived_likes`"
  end

  def options(slop)
    share_archive_options slop, :like
  end

  private

  def read_tweets
    read_and_filter method(:tweet_reader),
                    method(:filter_archive_tweets),
                    max_id
  end

  def tweet_reader
    tweets = user_likes(user, tweet_mode: 'extended', max_id: max_id)
    tweets.tap { self.max_id = tweets[-1]&.id }
  end

  def print_total(total)
    line.rewind.print "#{total} likes archived"
    throw(:cancel) if opts[:max].nonzero? && total == opts[:max]
  end

  add_command self
end
