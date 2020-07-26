class TWEnv::ArchiveTimeline < TWEnv::Command
  match 'archive-timeline'
  description 'Archive a timeline of tweets'
  command_options argument_required: true, storage: true
  group 'twenv'
  banner <<-BANNER
  archive-timeline [options] USER

  #{description}
  BANNER

  attr_accessor :user, :path, :max_id
  include TWEnv::Command::ArchiveCommand

  def process(user)
    self.user = user
    self.path = File.join storage_path, "#{user}.json"
    archive = opts['continue'] ? read_archive(path) : []
    opts['continue'] ? resume_from_previous_archive(archive) : write_archive(path, archive)
    perform_action_on_tweets method(:read_tweets),
                             method(:archive_tweet),
                             method(:print_total),
                             archive.map(&:id)
    line.end
    complete_archive(path, archive, local_name: "archived_timeline")
  rescue TWEnv::Error::NoSuchArchiveError
    line.error("Can't continue because an archive for #{user} doesn't exist").end
  rescue Twitter::Error => ex
    line.error("#{ex.message} (#{ex.class})").end
  rescue Interrupt
    line.end
    line.warn("Interrupt received").end
    complete_archive(path, archive, local_name: "archived_timeline")
  end

  def options(slop)
    share_archive_options slop, :tweet
    slop.on 'is-retweet'   , "Only archive tweets that are retweets", default: false, as: :boolean
    slop.on 'no-retweets'  , "Only archive tweets that aren't retweets", default: false, as: :boolean
    slop.on 'is-reply'     , "Only archive tweets that are replies", default: false, as: :boolean
    slop.on 'no-replies'   , "Only archive tweets that aren't replies", default: false, as: :boolean
    slop.on 'has-video'    , "Only archive tweets that have video", default: false, as: :boolean
    slop.on 'no-video'     , "Only archive tweets that don't have video", default: false, as: :boolean
  end

  private

  def read_tweets
    read_and_filter method(:timeline_tweets),
                    method(:filter_tweets),
                    max_id
  end

  def timeline_tweets
    user_timeline(user, tweet_mode: 'extended', max_id: max_id)
  end

  def filter_tweets(tweets)
    max_id = tweets[-1]&.id
    tweets = filter_archive_tweets(tweets)
    tweets.reject!(&:retweet?) if opts['no-retweets']
    tweets.select!(&:retweet?) if opts['is-retweet']
    tweets.select!(&:reply?) if opts['is-reply']
    tweets.reject!(&:reply?) if opts['no-replies']
    tweets.select!{|t| t.media.any?{|m| m.instance_of?(Twitter::Media::Video) } } if opts['has-video']
    tweets.reject!{|t| t.media.any?{|m| m.instance_of?(Twitter::Media::Video) } } if opts['no-video']
    tweets.tap { self.max_id = max_id }
  end

  def print_total(total)
    line.rewind.ok "#{total} tweets archived"
    throw(:cancel) if opts[:max].nonzero? && total == opts[:max]
  end

  add_command self
end
