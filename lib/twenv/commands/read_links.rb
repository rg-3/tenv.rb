class TWEnv::ReadLinks < TWEnv::Command
  match 'read-links'
  description 'Read tweets that include external links'
  group 'twenv'
  banner <<-BANNER
  read-links [OPTIONS] [user]

  #{description}

  #{Paint['Examples', :bold]}

  #{Paint['# Read links from the home timeline of `client.user`', :italic]}
  twenv.rb (main)> read-links

  #{Paint['# Read links from @rubyinside', :italic]}
  twenv.rb (main)> read-links rubyinside --max 75

  #{Paint['Options', :bold]}
  BANNER

  MAX_WIDTH = 80

  attr_accessor :max_id, :user

  def options(slop)
    slop.on :m, :max=, "The max number of links to find. Default is 25", as: :integer, default: 25
  end

  def process(user)
    self.user = user
    tweets = []
    perform_action_on_tweets method(:read_tweets),
                             lambda {|tweet| tweets.push(tweet) },
                             method(:print_total)
    line.end
    show_tweets(tweets)
  rescue Interrupt
    line.end
    line.warn("Interrupt received").end
    show_tweets(tweets)
  end

  private

  def read_tweets
    read_and_filter method(:timeline_tweets),
                    method(:filter_tweets),
                    max_id
  end

  def timeline_tweets
    options = {tweet_mode: 'extended', max_id: max_id}
    if user
      user_timeline(user, options)
    else
      home_timeline(options)
    end
  end

  def filter_tweets(tweets)
    tweets = tweets.dup
    max_id = tweets[-1]&.id
    tweets.select! {|t| t.urls.any? { |url| url.expanded_url.host != 'twitter.com' } }
    tweets.tap{ self.max_id = max_id }
  end

  def print_total(total)
    line.rewind.ok("found #{total} tweets with external links")
    throw(:cancel) if total == max
  end

  def show_tweets(tweets)
    out = tweets.map do |tweet,index|
      content = tweet.text.each_line.to_a[0].strip
      tweet.urls.each{|url| content = content.gsub(url.url.to_s, '').gsub(/\s*[-:]\s*$/, '')}
      content = "#{content[0..MAX_WIDTH-1]}..." if content.size >= MAX_WIDTH
      [
        Paint[format_time(tweet.created_at, :upcase), :bold],
        content,
        tweet.urls.map {|url| url.expanded_url.to_s }.join("\n")
      ].join("\n")
    end.join("\n\n")
    pager.page out
  end

  def max
    opts[:max]
  end

  add_command self
end
