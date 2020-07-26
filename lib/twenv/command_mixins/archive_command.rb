# frozen_string_literal: true

module TWEnv::Command::ArchiveCommand
  def share_archive_options(slop, object_name = :tweet)
    slop.on :m, :max=            , "The max number of #{object_name}s to archive. Default is unlimited", default: 0, as: :integer
    slop.on "has-media"          , "Only archive #{object_name}s that have media (either video or image)", default: false
    slop.on "no-media"           , "Only archive #{object_name}s that don't have media (either video or image)", default: false
    slop.on "has-links"          , "Only archive #{object_name}s that have links", default: false, as: :boolean
    slop.on "no-links"           , "Only archive #{object_name}s that don't have links", default: false, as: :boolean
    slop.on "has-outbound-links" , "Only archive #{object_name}s that link to somewhere outside Twitter", default: false, as: :boolean
    slop.on "c", "continue"      , "Continue from the last #{object_name} in a saved archive", default: false, as: :boolean
  end

  def filter_archive_tweets(tweets)
    tweets = tweets.dup
    tweets.select! {|t| t.urls.any? { |url| url.expanded_url.host != 'twitter.com' } } if opts['has-outbound-links']
    tweets.select! {|t| t.media.empty? }   if opts['no-media']
    tweets.select! {|t| t.media.size > 0 } if opts['has-media']
    tweets.select! {|t| t.urls.empty? }    if opts['no-links']
    tweets.select! {|t| t.urls.size > 0 }  if opts['has-links']
    tweets
  end

  def archive_tweet(tweet)
    write_archive path, read_archive(path).tap {|tweets| tweets.push(format_tweet(tweet)) }
  end

  def read_archive(path)
    tweets = JSON.parse File.read(path)
    tweets.map {|tweet| TWEnv::Struct.from_hash(tweet)}
  rescue Errno::ENOENT => ex
    raise TWEnv::Error::NoSuchArchiveError, ex.message
  end

  def write_archive(path, tweets)
    File.write path, JSON.dump(tweets)
  end

  def resume_from_previous_archive(archive)
    tweet = archive[-1]
    if tweet
      self.max_id = tweet.id
      line.ok("Continue from #{tweet.url} (#{tweet.created_at})").end
    else
      line.warn("Archive is empty. Continue from start.").end
    end
  end

  def complete_archive(path, old_archive, local_name:)
    archive = read_archive(path)
    return if old_archive == archive
    sticky_locals.merge!(local_name => archive)
    line.ok("Archive saved to #{relative_to_root(path)}").end
    line.ok("Archive assigned to local variable `#{local_name}`").end
  end
end
