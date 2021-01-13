class TWEnv::DeleteMyLikes < TWEnv::Command
  match 'delete-my-likes'
  description 'Delete tweets liked by `client.user`'
  group 'twenv'
  banner <<-BANNER
  delete-my-likes [OPTIONS] user

  #{description}
  BANNER

  attr_accessor :max_id

  def options(slop)
    slop.on 'is-reply'      , "Only delete likes that are replies", as: :boolean, default: false
    slop.on 'is-not-reply'  , "Only delete likes that are not replies", as: :boolean, default: false
    slop.on 'is-reply-to='  , "Only delete likes that are a reply to the given username", as: :string, default: nil
  end

  def process
    perform_action_on_tweets method(:read_tweets),
                             lambda {|tweet| client.unfavorite(tweet) },
                             lambda {|total| line.rewind.ok("#{total} tweets unliked") }
    line.end
  rescue Interrupt
    line.end
    line.warn("Interrupt received").end
  end

  private

  def read_tweets
    read_and_filter lambda { user_likes(client.user, max_id: max_id) },
                    method(:filter_likes),
                    max_id
  end

  def filter_likes(tweets)
    tweets = tweets.dup
    max_id = tweets[-1]&.id
    tweets.select!(&:reply?) if opts['is-reply'] || opts['is-reply-to']
    tweets.reject!(&:reply?) if opts['is-not-reply']
    is_reply_to_filter!(tweets, opts['is-reply-to'])
    tweets.tap{ self.max_id = max_id }
  end

  add_command self
end
