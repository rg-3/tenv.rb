class TWEnv::WriteTweet < TWEnv::Command
  match 'write-tweet'
  description "Write a tweet on behalf of `client.user`"
  group 'twenv'
  command_options storage: true
  banner <<-BANNER
  write-tweet [OPTIONS]

  #{description}

  #{Paint['Examples', :bold]}

  # Opens an editor and instantly publishes a tweet
  write-tweet

  # Delay for 60 seconds
  write-tweet --delay 60

  # Delay for 5 hours
  write-tweet --delay 5.hours

  # Delay for 1 day
  write-tweet --delay 1.day

  # Delay for 2 days
  write-tweet --delay 2.days

  # Delay using a 12-hour clock
  write-tweet --delay 1:00am

  # Delay using a 24-hour clock
  write-tweet --delay 19:00
  BANNER

  ONE_DAY = 3600 * 24

  def options(slop)
    slop.on :d, :delay=, 'Delay sending a tweet', as: :string, default: '0'
    slop.on :f, :files=, 'List of files to post with the tweet', as: :array, default: []
  end

  def process
    raise Pry::CommandError, "set $EDITOR and try again" if empty?(ENV['EDITOR'])
    files = opts[:files].map{|path| File.new(File.expand_path(path), 'r')}
    delay = parse_delay_option(opts[:delay])
    tweet = read_tweet
    Time.now >= delay ? post_tweet(tweet, files) : delay_tweet(tweet, files, delay)
  end

  private

  def post_tweet(tweet, files = [], print_progress=true)
    line.print "Posting tweet ... " if print_progress
    if files.empty?
      client.update(tweet)
    else
      client.update_with_media(tweet, files)
      files.each(&:close)
    end
    line.print("Done.").end if print_progress
  end

  def delay_tweet(tweet, files, delay_until)
    line.ok("tweet will be published at around #{bold(format_time(delay_until, :upcase))}. " \
            "If this twenv.rb process exits before then the tweet won't be published.").end
    Thread.new do
      sleep delay_until.to_i - Time.now.to_i
      post_tweet(tweet, files, false)
    end
  end

  def read_tweet
    file = Tempfile.new 'twenv', storage_path
    system ENV['EDITOR'], file.path
    raise Pry::CommandError, "editor failed with exit code #{$?.exitstatus}" if !$?.success?
    tweet = file.read
    raise Pry::CommandError, "tweet content is empty" if empty?(tweet)
    tweet
  ensure
    file.unlink
    file.close
  end

  def parse_delay_option(delay)
    case delay
    when /^\s*(\d+)\s*$/
      Time.now + Regexp.last_match[1].to_i
    when /^\s*(\d+)\.hours?\s*$/
      Time.now + (Regexp.last_match[1].to_i * 3600)
    when /^\s*(\d+)\.days?\s*$/
      Time.now + (Regexp.last_match[1].to_i * ONE_DAY)
    when /^\s*(\d+):(\d+)(am|pm)?$/i
      make_time(Regexp.last_match[1], Regexp.last_match[2], Regexp.last_match[3])
    else
      raise Pry::CommandError, "The --delay option is not valid"
    end
  end

  def make_time(hour, minute, median)
    if median
      # 12 hour clock
      time_obj = Time.strptime("#{hour}:#{minute} #{median.downcase}", "%I:%M %P")
    else
      # 24 hour clock
      time_obj = Time.strptime("#{hour}:#{minute}", "%H:%M", "%k:%M")
    end
    time_obj < Time.now ? time_obj + ONE_DAY : time_obj
  rescue ArgumentError
    raise Pry::CommandError, "The --delay option couldn't be parsed into a Time object"
  end

  def empty?(o)
    o.nil? || o.strip.empty?
  end

  add_command self
end
