class Tenv::Command < Pry::ClassCommand
  require 'word_wrap'
  BACKSPACE_CHAR = "\010"

  def self.inherited(klass)
    Thread.new do
      # After 0.5 seconds a command ought to have called 'match',
      # but this obviously sucks :)
      sleep 0.5
      klass.group 'tenv'
      Pry.commands.add_command(klass)
    end
  end

  def word_wrap(str, cols: 80, fit: true)
    WordWrap.ww str, cols, fit
  end

  def clear_line(width = 1024)
    print BACKSPACE_CHAR*width
  end

  def client
    pry_instance.config.extra_sticky_locals[:client]
  end

  def user_timeline(user, max_id=nil)
    max_id ? client.user_timeline(user, max_id: max_id) : client.user_timeline(user)
  end

  def perform_action_on_tweets(read_tweets, perform_action, on_action)
    total ||= 0
    tweets = read_tweets.call
    until tweets.empty?
      tweets.each do |tweet|
        perform_action.call(tweet)
        total += 1
        on_action.call(tweet, total)
      end
      tweets = read_tweets.call
    end
    on_action.call(nil, total)
    print "\n"
  rescue Twitter::Error::TooManyRequests => e
    clear_line
    print "Rate limited. Retrying in #{e.retry_after} seconds"
    sleep e.retry_after
    retry
  end
end
