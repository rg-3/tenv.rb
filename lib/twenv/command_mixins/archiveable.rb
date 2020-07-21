# frozen_string_literal: true

module TWEnv::Command::Archiveable
  def share_archive_options(slop, object_name = 'tweets')
    slop.on :m, :max=             , "The max number of #{object_name} to archive. Default is unlimited", default: 0, as: :integer
    slop.on :"outbound-links-only", "Only archive #{object_name} that link to somewhere outside Twitter", default: false, as: :boolean
    slop.on :"no-media"           , "Only archive #{object_name} that don't include media (ie: video, images)", default: false
    slop.on :"media-only"         , "Only archive #{object_name} that include media (ie: video, images)", default: false
    slop.on :"no-links"           , "Only archive #{object_name} that don't include links", default: false, as: :boolean
    slop.on :"links-only"         , "Only archive #{object_name} that include links", default: false, as: :boolean
  end

  def filter_archive_tweets(tweets)
    tweets = tweets.dup
    tweets.select! {|t| t.urls.any? { |url| url.expanded_url.host != 'twitter.com' } } if opts['outbound-links-only']
    tweets.select! {|t| t.media.empty? }   if opts['no-media']
    tweets.select! {|t| t.media.size > 0 } if opts['media-only']
    tweets.select! {|t| t.urls.empty? }    if opts['no-links']
    tweets.select! {|t| t.urls.size > 0 }  if opts['links-only']
    tweets
  end
end
