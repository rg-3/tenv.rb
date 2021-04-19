class TWEnv::ArchiveLikes < TWEnv::Command
  match "archive-likes"
  description "Archive the likes of a Twitter account"
  command_options argument_required: true, storage: true
  group "twenv"
  banner <<-BANNER
  archive-likes [options] USER

  #{description}
  BANNER

  attr_accessor :user, :path, :max_id
  include TWEnv::Command::ArchiveCommand

  def process(user)
    self.user = user
    self.path = File.join storage_path, "#{user}.json"
    archive = opts["continue"] ? read_archive(path) : []
    opts["continue"] ? resume_from_previous_archive(archive) : write_archive(path, archive)
    perform_action_on_tweets method(:read_tweets),
      method(:archive_tweet),
      method(:print_total),
      archive.map(&:id)
    line.end
    complete_archive(path, archive, local_name: "archived_likes")
  rescue TWEnv::Error::ArchiveNotFoundError
    line.error("Can't continue because an archive for #{user} doesn't exist").end
  rescue Twitter::Error => ex
    line.error("#{ex.message} (#{ex.class})").end
  rescue Interrupt
    line.end
    line.warn("Interrupt received").end
    complete_archive(path, archive, local_name: "archived_likes")
  end

  def options(slop)
    share_archive_options slop, :like
  end

  private

  def read_tweets
    read_and_filter method(:liked_tweets),
      method(:filter_likes),
      max_id
  end

  def filter_likes(likes)
    max_id = likes[-1]&.id
    likes = filter_archive_tweets(likes)
    likes.tap { self.max_id = max_id }
  end

  def liked_tweets
    user_likes(user, tweet_mode: "extended", max_id: max_id)
  end

  def print_total(total)
    line.rewind.ok "#{total} likes archived"
    throw(:cancel) if opts[:max].nonzero? && total == opts[:max]
  end

  add_command self
end
