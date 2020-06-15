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

  def perform_action_on_tweets(get_tweets, perform_action, on_action)
    total ||= 0
    tweets = get_tweets.call
    until tweets.empty?
      tweets.each do |tweet|
        perform_action.call(tweet)
        total += 1
        on_action.call(total)
      end
      tweets = get_tweets.call
    end
    on_action.call(total)
    print "\n"
  rescue Twitter::Error::TooManyRequests => e
    clear_line
    print "Rate limited. Retrying in #{e.retry_after} seconds"
    sleep e.retry_after
    retry
  end
end
