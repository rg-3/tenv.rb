class TWEnv::WriteTweet < TWEnv::Command
  match 'write-tweet'
  description "Write a tweet on behalf of `client.user`"
  group 'twenv'
  command_options storage: true, shellwords: false
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

  # Delay a tweet until Christmas Eve morning, 2022
  write-tweet --delay 09:00AM --delay-date 24/12/2022
  BANNER

  include Twitter::TwitterText::Validation

  ScheduledTweet = Struct.new(:body, :files, :delay_until, :thr, :scheduled_tweets) do
    def abort
      scheduled_tweets.delete(self)
      thr.kill
    end
  end

  ST_TMPL = <<-TMPL.each_line.map(&:lstrip).join
  %{index}
  #{Paint['When:', :bold]} %{time}
  #{Paint['Contents:', :bold]} %{body}
  #{Paint['Files:', :bold]} %{files}
  \n
  TMPL

  ONE_DAY = 3600 * 24

  def options(slop)
    slop.on :d,  :delay=         , 'Delay sending a tweet', as: :string, default: '0'
    slop.on :f,  :files=         , 'List of files to post with the tweet', as: :array, default: []
    slop.on :r,  'in-reply-to='  , 'Write a reply to the given tweet', as: :boolean, default: nil
    slop.on :s,  'show-schedule' , 'Show at what time delayed tweet(s) are scheduled to be published', as: :boolean, default: nil
    slop.on      'delay-date='   , 'The date to which the --delay option should be relative to. Defaults to today', as: :string, default: nil
    slop.on :c,  'cancel='       , 'Cancel the publish of a delayed tweet with an index number taken from --show-schedule', as: :integer, default: nil
  end

  def process
    raise Pry::CommandError, "set $EDITOR and try again" if empty?(ENV['EDITOR'])
    if opts['show-schedule']
      show_scheduled_tweets
    elsif opts['cancel']
      cancel_tweet(opts['cancel'])
    else
      files = opts[:files].map{|path| File.new(File.expand_path(path), 'r')}
      delay = parse_delay_option(opts[:delay])
      body = write_tweet
      body, options = parse_reply_to_option(body, opts['in-reply-to'])
      body = edit(body) while too_long?(body)
      return unless body
      Time.now >= delay ? post_tweet(body, files, options) : delay_tweet(body, files, options, delay)
    end
  end

  private

  def parse_reply_to_option(tweet, reply_to)
    return [tweet, {}] unless reply_to
    status   = client.status(reply_to)
    author   = "@#{status.user.screen_name}"
    mentions = status.user_mentions.map {|u| "@#{u.screen_name}" }.join(' ')
    tweet = "#{author} #{mentions} #{tweet}"
    [tweet, {in_reply_to_status: status}]
  end

  def post_tweet(tweet, files, options, print_progress=true)
    line.print "Posting tweet ... " if print_progress
    if files.empty?
      client.update(tweet, options)
    else
      client.update_with_media(tweet, files, options)
      files.each(&:close)
    end
    line.print("Done.").end if print_progress
  end

  def delay_tweet(tweet, files, options, delay_until)
    line.ok("tweet will be published at around #{bold(format_time(delay_until, :upcase))}. " \
            "If this twenv.rb process exits before then the tweet won't be published.").end
    thr = Thread.new do
      sleep delay_until.to_i - Time.now.to_i
      post_tweet(tweet, files, options, false)
    ensure
      tweet = scheduled_tweets.find{|tweet| tweet.thr == thr}
      tweet.abort if tweet
    end
    scheduled_tweets.push ScheduledTweet.new(tweet, files, delay_until, thr, scheduled_tweets)
  end

  def write_tweet(contents='')
    file = Tempfile.new 'twenv', storage_path
    File.write file.path, contents
    system ENV['EDITOR'], file.path
    raise Pry::CommandError, "editor failed with exit code #{$?.exitstatus}" if !$?.success?
    tweet = file.read
    raise Pry::CommandError, "tweet content is empty" if empty?(tweet)
    tweet
  ensure
    file.unlink
    file.close
  end

  def edit(tweet)
    line.warn("Your tweet is too long. Press enter to edit the tweet and try again. Press ^C to cancel. ")
    $stdin.gets
    write_tweet(tweet)
  rescue Interrupt
    line.end.warn("Interrupt received").end
    nil
  end

  def show_scheduled_tweets
    if scheduled_tweets.empty?
      line.info("There are no delayed tweets scheduled to be published").end
    else
      pager.page [
        scheduled_tweets
          .sort_by(&:delay_until) # ASC sort
          .map
          .with_index(1) {|t, i|
            format ST_TMPL, body: t.body.chomp, files: t.files.empty? ? 'None' : t.files.map(&:path).join(','),
                            index: blue(bold("##{i}")), time: format_time(t.delay_until, :upcase)
          }
      ].flatten.join("\n")
    end
  end

  def cancel_tweet(cancel_index)
    tweet = scheduled_tweets
      .sort_by(&:delay_until) # ASC sort
      .find
      .with_index(1) { |_, index| index == cancel_index }
    if tweet
      tweet.abort
      line.ok("The delayed tweet was successfully cancelled and will not be published").end
    else
      line.error("A delayed tweet at the given index was not found").end
    end
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
    delay_date = opts['delay-date'] || Date.today.strftime('%d/%m/%Y')
    if median
      # 12 hour clock
      time_obj = Time.strptime("#{hour}:#{minute} #{median.downcase} #{delay_date}", "%I:%M %P %d/%m/%Y")
    else
      # 24 hour clock
      time_obj = Time.strptime("#{hour}:#{minute} #{delay_date}", "%H:%M %d/%m/%Y")
    end
    time_obj < Time.now ? time_obj + ONE_DAY : time_obj
  rescue ArgumentError
    raise Pry::CommandError, "The --delay option couldn't be parsed into a Time object"
  end

  def empty?(tweet)
    tweet.nil? || tweet.strip.empty?
  end

  def too_long?(tweet)
    return false unless tweet
    result = parse_tweet(tweet)
    result[:weighted_length] > 280
  end

  def scheduled_tweets
    state[:schedule]
  end

  def state
    super[:write_tweets] ||= {schedule: []}
  end

  add_command self
end
